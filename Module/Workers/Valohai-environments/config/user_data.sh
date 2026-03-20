#!/bin/bash

set -xeuo pipefail
sudo apt-get -o DPkg::Lock::Timeout=-1 update || true
sudo apt-get -o DPkg::Lock::Timeout=-1 install jq -y

# Set up the environments
echo "${file("${module_path}/config/prep_template.yaml")}" > /home/ubuntu/prep_template.yaml

export VH_TOKEN=`aws ssm get-parameter --name 'dev-valohai-app-token' --with-decryption | sed -n 's|.*"Value": *"\([^"]*\)".*|\1|p'`
sed -i "s|valohai-token: ''|valohai-token: '$VH_TOKEN'|" /home/ubuntu/prep_template.yaml
unset VH_TOKEN

sed -i "s|valohai-url: ''|valohai-url: '${url_base}'|" /home/ubuntu/prep_template.yaml
sed -i "s|valohai-env-name-prefix: ''|valohai-env-name-prefix: '${env_name_prefix}'|" /home/ubuntu/prep_template.yaml
sed -i "s|asg-name-prefix: ''|asg-name-prefix: '${env_asg_prefix}'|" /home/ubuntu/prep_template.yaml
sed -i "s|queue-name-prefix: ''|queue-name-prefix: '${env_queue_prefix}'|" /home/ubuntu/prep_template.yaml
sed -i "s|region: ''|region: '${region}'|" /home/ubuntu/prep_template.yaml
sed -i "s|redis-url: ''|redis-url: 'redis://${redis_url}:6379'|" /home/ubuntu/prep_template.yaml
sed -i "s|security-group-name: ''|security-group-name: 'dev-valohai-sg-workers'|" /home/ubuntu/prep_template.yaml
sed -i "s|vpc-id: ''|vpc-id: '${worker_vpc_id}'|" /home/ubuntu/prep_template.yaml
sed -i "s|key-pair-name: ''|key-pair-name: 'dev-valohai-key-workers'|" /home/ubuntu/prep_template.yaml
echo "  ${aws_instance_types}" >> /home/ubuntu/prep_template.yaml
echo "  ${aws_spot_instance_types}" >> /home/ubuntu/prep_template.yaml

sed -i "s|valohai-env-owner-id: ''|valohai-env-owner-id: '${organization}'|" /home/ubuntu/prep_template.yaml

# Check if we need cross-account access
if [ "${aws_account_id}" != "${aws_worker_account_id}" ]; then
  echo "Setting up cross-account access to worker account..."

  # Assume worker account role
  WORKER_ROLE_ARN="arn:aws:iam::${aws_worker_account_id}:role/dev-valohai-iamr-master"

  CREDS=$(aws sts assume-role \
    --role-arn "$WORKER_ROLE_ARN" \
    --role-session-name "valohai-environment-setup" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text)

  export AWS_ACCESS_KEY_ID=$(echo $CREDS | awk '{print $1}')
  export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | awk '{print $2}')
  export AWS_SESSION_TOKEN=$(echo $CREDS | awk '{print $3}')

  # Add the Valohai Master role to the environment
  sed -i "18i\  scaling-role-arn: '$WORKER_ROLE_ARN'" /home/ubuntu/prep_template.yaml

else
  echo "Workers in same account - no cross-account access needed"
fi

# Run the prep script
su ubuntu -c "python3 -m prep --config-yaml /home/ubuntu/prep_template.yaml aws"

# Shutdown
shutdown -h now
