#!/bin/bash

# Define the GitHub repository URL where the Dockerfile and entrypoint.sh are hosted
REPO_URL="https://raw.githubusercontent.com/yoazmenda/dev-container/main"

# Prompt for ngrok auth token and SSH public key with hidden input
echo "Enter your Ngrok Auth Token: "
read -s NGROK_AUTH_TOKEN
echo "Enter your SSH Public Key: "
read -s SSH_PUBLIC_KEY

# Download Dockerfile and entrypoint.sh from the repository
echo "Downloading Dockerfile and entrypoint.sh..."
curl -sSL "$REPO_URL/Dockerfile" -o Dockerfile
curl -sSL "$REPO_URL/entrypoint.sh" -o entrypoint.sh

# Ensure entrypoint.sh is executable
chmod +x entrypoint.sh

# Build the Docker image
echo "Building Docker image..."
docker build --build-arg NGROK_AUTH_TOKEN="$NGROK_AUTH_TOKEN" --build-arg SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" -t dev-image .

# Cleanup the downloaded Dockerfile and entrypoint.sh
echo "Cleaning up temporary files..."
rm Dockerfile entrypoint.sh

# Run the Docker container
echo "Running Docker container..."
docker run -d -e NGROK_AUTH_TOKEN="$NGROK_AUTH_TOKEN" -e SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" --name dev-container dev-image

echo "Container started. Setting up ngrok and SSH..."

# Wait for ngrok to initialize and fetch the URL
echo "Fetching ngrok URL..."
MAX_ATTEMPTS=5
ATTEMPT_NUM=1
while [ $ATTEMPT_NUM -le $MAX_ATTEMPTS ]; do
    NGROK_URL=$(docker exec dev-container sh -c "grep -o 'tcp://[0-9a-z.]*:[0-9]*' /ngrok.log" | head -n 1)
    if [ -z "$NGROK_URL" ]; then
        echo "Ngrok URL not found, trying again in 5 seconds..."
        sleep 5
        let ATTEMPT_NUM=ATTEMPT_NUM+1
    else
        echo "Ngrok URL: $NGROK_URL"
        break
    fi
done

if [ -z "$NGROK_URL" ]; then
    echo "Failed to retrieve ngrok URL after $MAX_ATTEMPTS attempts."
fi
