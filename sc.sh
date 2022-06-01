#!/bin/bash
sudo apt-get -y update
sudo apt-get -y install nginx
sudo systemctl restart nginx
sudo systemctl enable nginx