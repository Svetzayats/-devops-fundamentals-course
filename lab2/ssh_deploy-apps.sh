#!/bin/bash

SERVER_HOST_DIR=$(pwd)/nestjs-rest-api-feat-products-api
CLIENT_HOST_DIR=$(pwd)/shop-react-redux-cloudfront-cart-api

# destination folder names (can be changed)
SERVER_REMOTE_DIR=/var/app/lab2_server
CLIENT_REMOTE_DIR=/var/www/lab2_client

check_remote_dir_exists() {
  echo "Check if remote directories exist"

  if ssh ubuntu-sshuser "[ ! -d $1 ]"; then
    echo "Creating: $1"
	ssh -t ubuntu-sshuser "sudo bash -c 'mkdir -p $1 && chown -R %your_ssh_user_name%: $1'"
  else
    echo "Clearing: $1"
    ssh ubuntu-sshuser "sudo -S rm -r $1/*"
  fi
}

check_remote_dir_exists $SERVER_REMOTE_DIR
check_remote_dir_exists $CLIENT_REMOTE_DIR

echo "---> Building and copying server files - START <---"
echo $SERVER_HOST_DIR
cd $SERVER_HOST_DIR && npm run build
scp -Cr dist/* package.json ubuntu-sshuser:$SERVER_REMOTE_DIR
echo "---> Building and transfering server - COMPLETE <---"

echo "---> Building and copying client files - START <---"
echo $CLIENT_HOST_DIR
cd $CLIENT_HOST_DIR && npm run build
scp -Cr build/* package.json ubuntu-sshuser:$CLIENT_REMOTE_DIR

echo "---> Transfering cert and ngingx config - START <---"
scp -Cr $(pwd)/ssl_cert/ $(pwd)/devops-js-app.conf ubuntu-sshuser:$CLIENT_REMOTE_DIR

echo "---> Building and transfering - COMPLETE <---"