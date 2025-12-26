#!/bin/bash
 
# Get user-specified folder and port (optional)
TARGET_FOLDER=${1:-wallet-service-demo}
TARGET_PORT=${2:-8082}
 
# Navigate to the specified folder
if [ -d "$TARGET_FOLDER" ]; then
    echo "Navigating to folder: $TARGET_FOLDER"
    cd "$TARGET_FOLDER"
else
    echo "Error: Folder '$TARGET_FOLDER' does not exist."
    exit 1
fi
 
# Stop any service running on the specified port
if lsof -i:"$TARGET_PORT" &> /dev/null; then
    echo "Stopping service running on port $TARGET_PORT..."
    PID=$(lsof -t -i:"$TARGET_PORT")
    kill -9 "$PID"
    echo "Service on port $TARGET_PORT stopped."
else
    echo "No service running on port $TARGET_PORT."
fi
 
# Perform Maven clean and package
if [ -f "./mvnw" ]; then
    echo "Running Maven clean and package..."
    ./mvnw clean package -DskipTests
    echo "Maven build completed."
else
    echo "Error: Maven wrapper (mvnw) not found in $TARGET_FOLDER."
    exit 1
fi
 
# Run the Quarkus application
echo "Starting Quarkus application..."
nohup java \
-Dquarkus.http.port="$TARGET_PORT" \
-jar target/quarkus-app/quarkus-run.jar > quarkus.log 2>&1 &
 
# Notify the user
echo "Quarkus application started. Logs are being written to quarkus.log"
