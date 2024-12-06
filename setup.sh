#!/bin/bash

set -e  
sudo apt update -y
sudo apt install -y python-pip
wget -q https://download.redis.io/releases/redis-6.2.4.tar.gz
tar xzf redis-6.2.4.tar.gz
cd redis-6.2.4
make
cd ..
sudo apt install -y redis-tools redis-server
sudo redis-server --daemonize yes
pip install -r requirements.txt
cd azure-vote/
sudo nohup python main.py > app.log 2>&1 &
