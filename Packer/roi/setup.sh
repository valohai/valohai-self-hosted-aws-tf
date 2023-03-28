set -x
export DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
sudo apt-get update -y
sudo apt-get update
sudo apt-get install -y -qq ca-certificates curl gnupg lsb-release python3-pip unzip

# Setup AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Setup AWS CLI to use Instance Profile credentials
sudo mkdir /home/ubuntu/.aws
sudo cp /tmp/credentials /home/ubuntu/.aws/credentials
export AWS_PROFILE=default

# Setup roi config files
sudo cp /tmp/roi.config /etc/roi.config
sudo cp /tmp/roi.service /etc/systemd/system/roi.service

# Setup docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

sudo systemctl start docker

# Download latest Valohai Roi image
aws ecr get-login-password --region eu-west-1 | sudo docker login --username AWS --password-stdin 905675611115.dkr.ecr.eu-west-1.amazonaws.com
sudo docker pull 905675611115.dkr.ecr.eu-west-1.amazonaws.com/valohai/roi:latest
sudo docker tag 905675611115.dkr.ecr.eu-west-1.amazonaws.com/valohai/roi:latest valohai/roi:latest

sudo systemctl daemon-reload
sudo systemctl enable roi