#!/bin/bash -xe
# This Script Starts a Bastion Instance 

ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" ]]; then
    ARCH="arm64"
    ARCHY="aarch64"
elif [[ "$ARCH" == "x86_64" ]]; then
    ARCH="amd64"
    ARCHY="x86_64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

sudo yum update -y
sudo yum install docker jq wget tar git -y
sudo systemctl enable --now docker 
sudo chown -R "${remote_user}":"${remote_user}" /var/run/docker.sock
sudo yum remove awscli -y
sudo rm -rf /usr/bin/aws
sudo rm -rf /usr/local/aws-cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-$ARCHY.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)
sudo mkdir -p /usr/local/bin
sudo curl -SL "https://github.com/docker/compose/releases/download/$VERSION/docker-compose-linux-$ARCHY" -o "/usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose

mkdir -p /home/${remote_user}/bin/
touch /home/${remote_user}/bin/find_servers
cat <<EOF > /home/${remote_user}/bin/find_servers
#!/bin/bash
aws ec2 describe-instances --region ${region-master} | jq .Reservations[].Instances[] | jq 'select(.Tags[].Value=="${deploy-name}*"  )' | jq '{"${deploy-name}": .NetworkInterfaces[0].PrivateIpAddresses[0].PrivateIpAddress}'
EOF
chmod +x /home/${remote_user}/bin/find_servers
chmod 600 /home/${remote_user}/.ssh/id_rsa
export PATH=/usr/local/bin:$PATH
echo 'export PATH=/usr/local/bin:$PATH' >> ~/.bashrc

# Download and install Node Exporter
LATEST=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | jq -r .tag_name)
VERSION=$(echo "$LATEST" | sed 's/v//')
wget https://github.com/prometheus/node_exporter/releases/download/$LATEST/node_exporter-$VERSION.linux-$ARCH.tar.gz -P /home/${remote_user}/
tar xvzf /home/${remote_user}/node_exporter-$VERSION.linux-$ARCH.tar.gz -C /home/${remote_user}/
sudo cp /home/${remote_user}/node_exporter-$VERSION.linux-$ARCH/node_exporter /usr/bin/
sudo useradd -rs /bin/false node_exporter
rm -rf /home/${remote_user}/node_exporter-$VERSION.linux-$ARCH.tar.gz

# Create and enable Node Exporter service
sudo tee /etc/systemd/system/node_exporter.service << EOF 
[Unit]
Description=Node Exporter
After=network.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/bin/node_exporter --collector.systemd
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

#Create Secure Tunnel Service
sudo tee /etc/systemd/system/secure-tunnel@.service << EOF
[Unit]
Description=Setup a secure tunnel to %I
After=network.target
[Service]
Environment="LOCAL_ADDR=localhost"
EnvironmentFile=/etc/default/secure-tunnel@%i
ExecStart=/usr/bin/ssh -vvv -i /home/ec2-user/.ssh/id_rsa -NT -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -o UserKnownHostsFile=/home/ec2-user/.ssh/known_hosts -L $${LOCAL_ADDR}:$${LOCAL_PORT}:$${REMOTE_ADDRESS}:$${REMOTE_PORT} ec2-user@$${TARGET}
# Restart every >2 seconds to avoid StartLimitInterval failure
RestartSec=5
Restart=always
[Install]
WantedBy=multi-user.target
EOF

#Install Cadvisor
sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  --restart=always \
  gcr.io/cadvisor/cadvisor