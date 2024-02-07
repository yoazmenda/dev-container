#!/bin/bash

# Variables
DOCKER_IMAGE_NAME="ubuntu-custom"
CONTAINER_NAME="ubuntu-custom-container"
SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"
REPO_URL="https://raw.githubusercontent.com/yoazmenda/dev-container/main"

# Check if SSH key exists, if not, suggest creating one
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "SSH key not found at $SSH_KEY_PATH."
    echo "Consider running 'ssh-keygen -t rsa -b 4096' to create a new SSH key."
    exit 1
fi

# Fetch and build the Docker image from the remote Dockerfile
echo "Fetching Dockerfile and building image..."
curl -sSL "$REPO_URL/Dockerfile" | docker build -t $DOCKER_IMAGE_NAME -

# Run the Docker container with SSH key mounted
echo "Running the Docker container..."
docker run -d -p 2222:22 -v $SSH_KEY_PATH:/home/user/.ssh/authorized_keys:ro --name $CONTAINER_NAME $DOCKER_IMAGE_NAME

# Set the correct permissions for the authorized_keys
echo "Setting correct permissions for authorized_keys..."
docker exec $CONTAINER_NAME chown user:user /home/user/.ssh/authorized_keys
docker exec $CONTAINER_NAME chmod 600 /home/user/.ssh/authorized_keys

echo "Container setup complete. You can now SSH into the container using:"
echo "ssh -p 2222 user@localhost"
