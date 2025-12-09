#!/bin/bash

REMOTE_NAME="gdrive"

check_if_rclone_installed() {
    if ! command -v rclone &> /dev/null; then
        echo "rclone is not installed. Installing..."
        install_rclone
    else
        echo "rclone is already installed"
        rclone version
    fi
}



install_rclone() {
    echo "Installing rclone..."
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux installation
        if command -v apt-get &> /dev/null; then
            # Debian/Ubuntu
            sudo apt-get update
            sudo apt-get install -y rclone
        elif command -v yum &> /dev/null; then
            # RedHat/CentOS
            sudo yum install -y rclone
        elif command -v dnf &> /dev/null; then
            # Fedora
            sudo dnf install -y rclone
        else
            # Universal method - official script
            curl https://rclone.org/install.sh | sudo bash
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install rclone
        else
            echo "Homebrew not found. Installing via official script..."
            curl https://rclone.org/install.sh | sudo bash
        fi
    else
        echo "Unsupported OS. Please install rclone manually from https://rclone.org/downloads/"
        exit 1
    fi
    
    # Verify installation
    if command -v rclone &> /dev/null; then
        echo "rclone installed successfully!"
        rclone version
    else
        echo "Failed to install rclone"
        exit 1
    fi
}


check_rclone_auth() {
    # Check if remote is configured
    if rclone listremotes | grep -q "^${REMOTE_NAME}:$"; then
        echo "Rclone remote '$REMOTE_NAME' exists"
    else
        echo "Error: Remote '$REMOTE_NAME' not configured"
        echo "Setting up rclone for Google Drive..."
        rclone config create gdrive drive
        
        # Verify it was created
        if rclone listremotes | grep -q "^${REMOTE_NAME}:$"; then
            echo "Remote configured successfully"
        else
            echo "Failed to configure remote"
            exit 1
        fi
    fi
}
check_if_rclone_installed
check_rclone_auth


chmod +x script.sh

cp script.sh /usr/local/bin/backup 

echo 