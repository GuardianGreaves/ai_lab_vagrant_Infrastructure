#!/bin/bash

set -e

echo "=== Update system ==="

apt update
apt upgrade -y


echo "=== Install Docker ==="

apt install -y docker.io docker-compose-plugin

systemctl enable docker
systemctl start docker


echo "=== Load variables ==="

if [ -f /vagrant/.env ]; then
    source /vagrant/.env
else
    echo ".env file not found"
    exit 1
fi


echo "=== Create Wiki.js volume ==="

docker volume create wikijs_data


echo "=== Start Wiki.js container ==="

docker run -d \
  --name wikijs \
  --restart always \
  -p 3000:3000 \
  -v wikijs_data:/wiki/data \
  -e DB_TYPE=postgres \
  -e DB_HOST=$POSTGRES_HOST \
  -e DB_PORT=5432 \
  -e DB_USER=$WIKI_USER \
  -e DB_PASS=$WIKI_PASSWORD \
  -e DB_NAME=$WIKI_DB \
  ghcr.io/requarks/wiki:2


echo "=== Waiting Wiki.js start ==="

sleep 20


echo "=== Check container ==="

docker ps | grep wikijs


echo "=== Wiki.js installation complete ==="

echo "Open:"
echo "http://192.168.56.13:3000"