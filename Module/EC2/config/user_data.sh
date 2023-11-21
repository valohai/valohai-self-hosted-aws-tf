#!/bin/bash

set -xeuo pipefail
sudo apt-get update

sudo systemctl stop roi
export ROI_AUTO_MIGRATE=true

echo "${file("${module_path}/config/roi.config")}" > /etc/roi.config

export REPO_PRIVATE_KEY=`aws ssm get-parameter --name ${repo_private_key} --with-decryption | sed -n 's|.*"Value": *"\([^"]*\)".*|\1|p'`
export SECRET_KEY=`aws ssm get-parameter --name ${secret_key} --with-decryption | sed -n 's|.*"Value": *"\([^"]*\)".*|\1|p'`
export JWT_KEY=`aws ssm get-parameter --name ${jwt_key} --with-decryption | sed -n 's|.*"Value": *"\([^"]*\)".*|\1|p'`

sed -i "s|URL_BASE=|URL_BASE=${url_base}|" /etc/roi.config
sed -i "s|AWS_REGION=|AWS_REGION=${region}|" /etc/roi.config
sed -i "s|AWS_S3_BUCKET_NAME=|AWS_S3_BUCKET_NAME=${s3_bucket}|" /etc/roi.config
sed -i "s|AWS_S3_KMS_KEY_ARN=|AWS_S3_KMS_KEY_ARN=${s3_kms_key}|" /etc/roi.config
sed -i "s|AWS_S3_MULTIPART_UPLOAD_IAM_ROLE=|AWS_S3_MULTIPART_UPLOAD_IAM_ROLE=arn:aws:iam::${aws_account_id}:role/dev-valohai-iamr-multipart|" /etc/roi.config
sed -i "s|CELERY_BROKER=|CELERY_BROKER=redis://${redis_url}:6379|" /etc/roi.config
sed -i "s|DATABASE_URL=|DATABASE_URL=psql://roi:${db_password}@${db_url}:5432/valohairoidb|" /etc/roi.config
sed -i "s|PLATFORM_LONG_NAME=|PLATFORM_LONG_NAME=${environment_name}|" /etc/roi.config
sed -i "s|REPO_PRIVATE_KEY_SECRET=|REPO_PRIVATE_KEY_SECRET=$REPO_PRIVATE_KEY|" /etc/roi.config
sed -i "s|SECRET_KEY=|SECRET_KEY=$SECRET_KEY|" /etc/roi.config
sed -i "s|STATS_JWT_KEY=|STATS_JWT_KEY=$JWT_KEY|" /etc/roi.config

sudo systemctl enable roi-setup
sudo systemctl start roi-setup
sudo systemctl enable roi
sudo systemctl restart roi
sudo snap start amazon-ssm-agent

echo "${file("${module_path}/config/prep_template.yaml")}" > /home/ubuntu/prep_template.yaml

export VH_TOKEN=`echo $RANDOM | md5sum | head -c 32; echo;`
sudo docker exec roi.service python manage.py shell -c "from roi.models import User;User.objects.filter(is_superuser=True).first().tokens.create(key='$VH_TOKEN')"
sed -i "s|valohai-token: ''|valohai-token: '$VH_TOKEN'|" /home/ubuntu/prep_template.yaml
unset VH_TOKEN

sed -i "s|valohai-url: ''|valohai-url: '${url_base}'|" /home/ubuntu/prep_template.yaml
sed -i "s|region: ''|region: '${region}'|" /home/ubuntu/prep_template.yaml
sed -i "s|redis-url: ''|redis-url: 'redis://${redis_url}:6379'|" /home/ubuntu/prep_template.yaml
sed -i "s|security-group-name: ''|security-group-name: 'dev-valohai-sg-workers'|" /home/ubuntu/prep_template.yaml
sed -i "s|vpc-id: ''|vpc-id: '${vpc_id}'|" /home/ubuntu/prep_template.yaml
sed -i "s|key-pair-name: ''|key-pair-name: 'dev-valohai-key-valohai'|" /home/ubuntu/prep_template.yaml
echo "  ${aws_instance_types}" >> /home/ubuntu/prep_template.yaml

set +xeuo pipefail
sudo docker exec roi.service python manage.py shell -c "from roi.models import Organization, User;import os;org = Organization.objects.create_user(username='${organization}', email='foo@example.org', is_organization=True)"
export ORG_ID=$(sudo docker exec roi.service python manage.py shell -c "from roi.models import Organization, User;org = User.objects.get(username='${organization}');print(str(org.id))")
sed -i "s|valohai-env-owner-id: ''|valohai-env-owner-id: '$ORG_ID'|" /home/ubuntu/prep_template.yaml

su ubuntu -c "python3 -m prep --config-yaml /home/ubuntu/prep_template.yaml aws"