#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y nginx python3-pip unzip redis-server

echo "
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
" | sudo tee /etc/nginx/sites-available/reverse-proxy.conf

sudo unlink /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf

sudo systemctl restart nginx
sudo systemctl enable nginx

sudo ufw allow 80/tcp

sudo ufw enable
sudo ufw status

sudo systemctl status nginx
