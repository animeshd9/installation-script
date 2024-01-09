#!/bin/bash


# Function to install necessary dependencies
install_dependencies() {
    # Check if jq is installed, if not, install it
    if ! command -v jq &> /dev/null; then
        echo "jq is not installed. Installing..."
        if sudo apt update && sudo apt install jq; then
            echo "jq installed successfully."
        else
            echo "Failed to install jq. Please check your internet connection or try again later."
            exit 1
        fi
    fi

    # Check if Node.js and npm are installed
    if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
        echo "Node.js and npm are required. Installing..."
        if sudo apt update && sudo apt install nodejs npm; then
            echo "Node.js and npm installed successfully."
        else
            echo "Failed to install Node.js and npm. Please check your internet connection or try again later."
            exit 1
        fi
    fi

    # Check if build-essential is installed
    if ! dpkg -s build-essential &> /dev/null; then
        echo "build-essential package is required. Installing..."
        if sudo apt install build-essential; then
            echo "build-essential installed successfully."
        else
            echo "Failed to install build-essential. Please check your internet connection or try again later."
            exit 1
        fi
    fi

    # Check if pm2 is installed, if not, install it
    if ! command -v pm2 &> /dev/null; then
        echo "pm2 is not installed. Installing..."
        if npm install -g pm2; then
            echo "pm2 installed successfully."
        else
            echo "Failed to install pm2. Please check your internet connection or try again later."
            exit 1
        fi
    fi
}

# Install necessary dependencies
install_dependencies


# Function to get the access token by logging in
get_access_token() {
    read -p "Enter your email: " username
    read -s -p "Enter your password: " password
    echo # for newline after password input

    # Make an API call to login and get the access token
    response=$(curl -s -X POST -H "Content-Type: application/json" -d '{"loginId": "'"$username"'", "password": "'"$password"'", "applicationId": "30e74f33-f9b0-4e2c-b98a-c4845f6543be"}' https://auth.setscharts.app/v1/api/user/login)
    # echo "$response" # Display the response (for debugging purposes)

    token=$(echo "$response" | jq -r '.token')
    if [ -z "$token" ]; then
        echo "Failed to get the access token. Please check your credentials."
        exit 1
    fi
}

# # Check if Node.js and npm are installed
# if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
#     echo "Node.js and npm are required. Installing..."
#     # Install Node.js and npm
#     sudo apt update
#     sudo apt install nodejs npm
# fi

# # Check if build-essential is installed
# if ! dpkg -s build-essential &> /dev/null; then
#     echo "build-essential package is required. Installing..."
#     # Install build-essential
#     sudo apt install build-essential
# fi

# # Install pm2 globally using npm if not installed
# if ! command -v pm2 &> /dev/null; then
#     echo "pm2 is not installed. Installing..."
#     npm install -g pm2
# fi

# Get the access token by logging in
get_access_token

# Clone the hammock repository to /tmp directory
echo "Cloning hammock repository to /tmp directory..."
git clone https://github.com/animeshd9/hammock.git /tmp/hammock

# Change directory to the cloned hammock repository
cd /tmp/hammock

# Install dependencies for hammock
echo "Installing dependencies for hammock..."
npm install

# Run hammock with pm2
echo "Starting hammock with pm2..."
pm2 start index.js  --name "hammock" -- start

# Clone the tunnel-service repository to /tmp directory
echo "Cloning tunnel-service repository to /tmp directory..."
git clone https://github.com/animeshd9/tunnel-service.git /tmp/tunnel-service

# Change directory to the cloned tunnel-service repository
cd /tmp/tunnel-service

# Install dependencies for tunnel-service
echo "Installing dependencies for tunnel-service..."
npm install

# Run the tunnel-service with pm2 using provided token as an environment variable
echo $token

if [ -n "$token" ]; then
    echo "Starting tunnel-service with pm2..."
    # pm2 start /tmp/tunnel-service/index.js --node-args="token=$token" --name "tunnel-service"
    # pm2 start /tmp/tunnel-service/index.js --name "tunnel-service" -- --token="$token"
    node index.js --token="$token"

else
    echo "Failed to get the access token for tunnel-service. Exiting..."
    exit 1
fi







