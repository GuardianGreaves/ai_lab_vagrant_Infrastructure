#!/bin/bash

set -e


echo "=== Updating system ==="

apt update
apt upgrade -y



echo "=== Installing Docker ==="

apt install -y docker.io curl


systemctl enable docker
systemctl start docker



echo "=== Add vagrant user to docker group ==="

usermod -aG docker vagrant



echo "=== Create Ollama volume ==="

docker volume create ollama_data



echo "=== Remove old Ollama container if exists ==="

docker rm -f ollama 2>/dev/null || true



echo "=== Start Ollama container ==="

docker run -d \
  --name ollama \
  --restart always \
  -p 11434:11434 \
  -v ollama_data:/root/.ollama \
  ollama/ollama



echo "=== Waiting Ollama ==="

sleep 15



echo "=== Download Mistral model ==="

docker exec ollama ollama pull mistral:latest



echo "=== Models list ==="

docker exec ollama ollama list



echo "=== Test Ollama API ==="

curl http://localhost:11434/api/tags



echo ""
echo "=== Ollama ready ==="

echo "API:"
echo "http://192.168.56.12:11434"