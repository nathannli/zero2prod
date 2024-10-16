#!/usr/bin/env bash
set -x
set -eo pipefail

# Container name as defined in init_db.sh
CONTAINER_NAME="postgres"

# Check if the container exists
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    # Stop the container
    docker stop ${CONTAINER_NAME}
    
    # Remove the container
    docker rm ${CONTAINER_NAME}
    
    echo "Container ${CONTAINER_NAME} has been stopped and removed."
else
    echo "Container ${CONTAINER_NAME} does not exist."
fi
