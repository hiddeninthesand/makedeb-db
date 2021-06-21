#!/usr/bin/env bash

# Create user
useradd user

# Set perms
chmod 777 * -R

# Build makedeb
cd src
sudo -u user './makedeb.sh'
