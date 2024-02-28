#!/bin/bash

# Prompt for ngrok auth token and SSH public key
read -p "Enter your Ngrok Auth Token: " NGROK_AUTH_TOKEN
read -p "Enter your SSH Public Key: " SSH_PUBLIC_KEY

# Build the Docker image
docker build --build-arg NGROK_AUTH_TOKEN="$NGROK_AUTH_TOKEN" --build-arg SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" -t dev-image .

# Run the Docker container
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

