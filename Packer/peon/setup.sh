set -x
export DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
sudo apt-get update -y
sudo apt-get install -y python3 python3-distutils unzip build-essential

# Setup AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Setup AWS CLI to use Instance Profile credentials
sudo mkdir /home/ubuntu/.aws
sudo cp /tmp/credentials /home/ubuntu/.aws/credentials
export AWS_PROFILE=default

# Setup roi config files
sudo cp /tmp/peon.config /etc/peon.config
sudo cp /tmp/peon.service /etc/systemd/system/peon.service
sudo cp /tmp/peon-clean.service /etc/systemd/system/peon-clean.service
sudo cp /tmp/peon-clean.timer /etc/systemd/system/peon-clean.timer
sudo cp /tmp/docker-prune.service /etc/systemd/system/docker-prune.service
sudo cp /tmp/docker-prune.timer /etc/systemd/system/docker-prune.timer

# Setup docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

sudo systemctl start docker

# Download and setup Peon and it's dependencies
cd /home/ubuntu/
wget "https://dist.valohai.com/peon-bringup/release/bup.pex"
chmod u+x bup.pex
sudo env "CLOUD=ec2" "INSTALLATION_TYPE=private" "REDIS_URL=none" "QUEUES=none" ./bup.pex

sudo systemctl daemon-reload
sudo systemctl enable peon-clean.timer
sudo systemctl start peon-clean.timer
sudo systemctl enable docker-prune.timer
sudo systemctl start docker-prune.timer

sudo systemctl restart peon
sudo snap start amazon-ssm-agent