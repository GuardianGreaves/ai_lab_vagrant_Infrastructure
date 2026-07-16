#!/bin/bash

set -e


echo "=== Load variables ==="

source /vagrant/variables.sh



echo "=== Updating system ==="

apt update
apt upgrade -y



echo "=== Installing Docker ==="

apt install -y docker.io docker-compose-plugin curl


systemctl enable docker
systemctl start docker



echo "=== Add vagrant user to docker group ==="

usermod -aG docker vagrant



echo "=== Create n8n directory ==="

mkdir -p /opt/n8n

chown -R 1000:1000 /opt/n8n



echo "=== Remove old n8n container ==="

docker rm -f n8n 2>/dev/null || true



echo "=== Start n8n container ==="


docker run -d \
  --name n8n \
  --restart always \
  -p 5678:5678 \
  -v /opt/n8n:/home/node/.n8n \
  -e DB_TYPE=postgresdb \
  -e DB_POSTGRESDB_HOST=192.168.56.10 \
  -e DB_POSTGRESDB_PORT=5432 \
  -e DB_POSTGRESDB_DATABASE=$N8N_DB \
  -e DB_POSTGRESDB_USER=$N8N_USER \
  -e DB_POSTGRESDB_PASSWORD=$N8N_PASSWORD \
  -e N8N_SECURE_COOKIE=false \
  -e N8N_HOST=192.168.56.11 \
  -e N8N_PORT=5678 \
  -e N8N_PROTOCOL=http \
  n8nio/n8n



echo "=== Waiting n8n start ==="

sleep 20



echo "=== Container status ==="

docker ps



echo "=== Check n8n port ==="

curl http://localhost:5678/



echo ""

echo "=== n8n ready ==="

echo "Open:"
echo "http://192.168.56.11:5678"