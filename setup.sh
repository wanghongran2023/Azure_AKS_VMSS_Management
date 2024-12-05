#!/bin/bash
sudo apt update     
sudo apt install python-pip -y
wget https://download.redis.io/releases/redis-6.2.4.tar.gz
tar xzf redis-6.2.4.tar.gz
cd redis-6.2.4
make
sudo apt install -y redis-tools
sudo apt install -y redis-server
redis-server --daemonize yes
cd ..      
pip install -r requirements.txt
cd azure-vote/      
python main.py
