#!/bin/bash

if [ -z "$1" ]; then
  echo "❌ Error: Please provide your Droplet IP address."
  echo "Usage: sudo ./local_dns.sh <DROPLET_IP>"
  exit 1
fi

DROPLET_IP=$1

echo "Updating /etc/hosts with Droplet IP: $DROPLET_IP..."

echo "" >> /etc/hosts
echo "# DigitalOcean IoT GitLab" >> /etc/hosts
echo "$DROPLET_IP    k3d.local gitlab.k3d.local" >> /etc/hosts

echo "\033[32mLocal DNS updated! You can now visit http://gitlab.k3d.local\033[0m"