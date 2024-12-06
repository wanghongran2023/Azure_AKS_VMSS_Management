#!/bin/bash

set -e  

sudo apt update -y
sudo apt install python3-pip -y
sudo -H pip3 install --upgrade pip
sudo apt-get install python3-venv -y
python3 -m venv venv
. venv/bin/activate

wget -q https://download.redis.io/releases/redis-6.2.4.tar.gz
tar xzf redis-6.2.4.tar.gz
cd redis-6.2.4
make
cd ..
sudo apt install -y redis-tools redis-server
sudo redis-server --daemonize yes

sudo python3 -m pip install --upgrade pip setuptools wheel
sudo python3 -m pip install setuptools-rust
sudo pip3 install -r requirements.txt

cd azure-vote/
sudo nohup python main.py > app.log 2>&1 &
