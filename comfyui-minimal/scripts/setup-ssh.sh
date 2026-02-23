#!/bin/bash
set -euo pipefail

apt update && apt install -y openssh-server
mkdir -p /var/run/sshd

sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config

if ! grep -q '^PasswordAuthentication no$' /etc/ssh/sshd_config; then
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
fi
