#!/bin/bash
 
# Variables
REPO_DIR="agentloans-web"   # Replace with the path to your Git repository
CONTAINER_NAME="agentloans-web"  # Replace with the name of your Docker container
IMAGE_NAME="agentloans-web"  # Replace with the desired Docker image name
 
# Navigate to the repository directory
cd "$REPO_DIR" || exit
 
# Pull the latest changes from the repository
echo "Pulling latest changes from Git..."
git pull
 
# Build the Docker image
echo "Building Docker image..."
docker build -t "$IMAGE_NAME" .
 
# Stop and remove the currently running container (if any)
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping and removing existing container..."
    docker stop "$CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
fi
 
# Run the new container
echo "Running the new container..."
docker run -d --name "$CONTAINER_NAME" -p 8086:3000 "$IMAGE_NAME"
 
echo "Deployment complete."
