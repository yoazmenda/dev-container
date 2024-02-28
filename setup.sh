#!/bin/bash

# Define repository URL for downloading additional required files
REPO_URL="https://raw.githubusercontent.com/yoazmenda/dev-container/main"

# Prompt for ngrok auth token with silent input
echo "Enter your Ngrok Auth Token (input will be hidden):"
read -s NGROK_AUTH_TOKEN
echo "Ngrok Auth Token received."

# Prompt for SSH public key with silent input
echo "Enter your SSH Public Key (input will be hidden):"
read -s SSH_PUBLIC_KEY
echo "SSH Public Key received."

# Download the Dockerfile and entrypoint.sh from the repository
echo "Downloading Dockerfile and entrypoint.sh..."
curl -sSL "$REPO_URL/Dockerfile" -o Dockerfile
curl -sSL "$REPO_URL/entrypoint.sh" -o entrypoint.sh

# Ensure entrypoint.sh is executable
chmod +x entrypoint.sh

# Build the Docker image
docker build --build-arg NGROK_AUTH_TOKEN="$NGROK_AUTH_TOKEN" --build-arg SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" -t dev-image .

# Clean up the downloaded files
echo "Cleaning up temporary files..."
rm Dockerfile entrypoint.sh

# Run the Docker container
docker run -d -e NGROK_AUTH_TOKEN="$NGROK_AUTH_TOKEN" -e SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" --name dev-container dev-image

echo "Container started. Setting up ngrok and SSH..."
