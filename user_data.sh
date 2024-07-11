#!/bin/bash

sudo su
yum update -y
yum install -y docker
service docker start
usermod -a -G docker ec2-user
docker run -p 80:80 --name app-orbbi marialazararibeiro/orbbi-app:latest