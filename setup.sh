#!/bin/bash

# Variables
DOCKER_IMAGE_NAME="ubuntu-custom"
CONTAINER_NAME="ubuntu-custom-container"
SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"
REPO_URL="https://raw.githubusercontent.com/johnsmith/dev-container/main"
BASE_PORT=2222

# Function to find an available port starting from BASE_PORT
find_available_port() {
    local port=$1
    while : ; do
        if ! lsof -i:$port &>/dev/null; then
            echo $port
            break
        fi
        ((port++))
    done
}

# Automatically remove old host key from known_hosts
update_known_hosts() {
    local port=$1
    ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "[localhost]:$port" &>/dev/null
}

# Check if SSH key exists, if not, suggest creating one
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "SSH key not found at $SSH_KEY_PATH."
    echo "Consider running 'ssh-keygen -t rsa -b 4096' to create a new SSH key."
    exit 1
fi

# Fetch and build the Docker image from the remote Dockerfile
echo "Fetching Dockerfile and building image..."
curl -sSL "$REPO_URL/Dockerfile" | docker build -t $DOCKER_IMAGE_NAME -

# Find an available port
AVAILABLE_PORT=$(find_available_port $BASE_PORT)
echo "Using available port: $AVAILABLE_PORT"

# Update known_hosts to prevent SSH host key verification error
update_known_hosts $AVAILABLE_PORT

# Run the Docker container with SSH key mounted and found available port
echo "Running the Docker container..."
docker run -d -p $AVAILABLE_PORT:22 -v $SSH_KEY_PATH:/home/user/.ssh/authorized_keys:ro --name $CONTAINER_NAME $DOCKER_IMAGE_NAME

echo "Container setup complete. Attempting to SSH into the container..."

# Wait a moment to ensure the SSH service is up
sleep 5

# Attempt to SSH into the container
ssh -o StrictHostKeyChecking=no -p $AVAILABLE_PORT user@localhost
