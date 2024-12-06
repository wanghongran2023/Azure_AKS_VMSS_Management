#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e  

# Update package list
sudo apt update -y

# Install Python pip
sudo apt install -y python-pip

# Download and install Redis
wget -q https://download.redis.io/releases/redis-6.2.4.tar.gz
tar xzf redis-6.2.4.tar.gz
cd redis-6.2.4
make
cd ..

# Install Redis tools and server
sudo apt install -y redis-tools redis-server

# Start Redis server in daemon mode
sudo redis-server --daemonize yes

# Install Python dependencies
pip install -r requirements.txt

# Navigate to the azure-vote directory and start the application
cd azure-vote/
sudo python main.py
