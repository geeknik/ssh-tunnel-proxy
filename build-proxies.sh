#!/bin/bash

# Number of droplets to create
NUM_DROPLETS=5

# DigitalOcean details
REGION="nyc3"
SIZE="s-1vcpu-1gb"
IMAGE="ubuntu-18-04-x64"
SSH_KEY_ID="your-ssh-key-id"

# SSH details
SSH_USER="root"
SSH_PASS="YOUR_PASSWORD"
SSH_PORT=12345  # local port for SSH tunnel

# Proxychains config file
PROXYCHAINS_CONF="/etc/proxychains.conf"

# Create droplets and setup SSH tunnel
for ((i=1; i<=NUM_DROPLETS; i++))
do
  # Create droplet
  DROPLET_ID=$(doctl compute droplet create droplet-$i --size $SIZE --image $IMAGE --region $REGION --ssh-keys $SSH_KEY_ID --format ID --no-header)

  # Wait for droplet to be active
  while [[ $(doctl compute droplet get $DROPLET_ID --format Status --no-header) != "active" ]]
  do
    sleep 5
  done

  # Get droplet IP
  DROPLET_IP=$(doctl compute droplet get $DROPLET_ID --format PublicIPv4 --no-header)

  # Setup SSH tunnel
  sshpass -p $SSH_PASS ssh -fN -D $SSH_PORT $SSH_USER@$DROPLET_IP

  # Add to Proxychains config
  echo "socks5 127.0.0.1 $SSH_PORT" >> $PROXYCHAINS_CONF

  # Increment local port for next SSH tunnel
  ((SSH_PORT++))
done
