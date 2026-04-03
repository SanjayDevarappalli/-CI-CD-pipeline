#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# provision_ec2.sh  —  Run ONCE on a fresh Ubuntu 22.04 EC2 instance
# Usage:  ssh ubuntu@<EC2_IP> 'bash -s' < scripts/provision_ec2.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

echo "==> Updating system packages"
sudo apt-get update -y
sudo apt-get upgrade -y

echo "==> Installing Docker"
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "==> Adding ubuntu user to docker group"
sudo usermod -aG docker ubuntu

echo "==> Enabling Docker service"
sudo systemctl enable docker
sudo systemctl start docker

echo "==> Creating production .env file"
cat > /home/ubuntu/.env.production <<'EOF'
DATABASE_URL=postgresql://taskuser:CHANGE_ME@db_host:5432/taskdb
SECRET_KEY=CHANGE_ME_TO_A_RANDOM_SECRET
FLASK_ENV=production
EOF
chmod 600 /home/ubuntu/.env.production
echo "!!! IMPORTANT: Edit /home/ubuntu/.env.production with real values !!!"

echo "==> Copying deploy script"
# deploy.sh is expected to already be present via git or scp
chmod +x /home/ubuntu/deploy.sh 2>/dev/null || true

echo ""
echo "==> EC2 provisioning complete!"
echo "    Re-login for docker group to take effect: ssh ubuntu@<IP>"
