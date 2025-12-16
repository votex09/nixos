#!/usr/bin/env bash

# This launcher script runs as the regular user to collect input,
# then passes it to the main install script running with sudo.

set -euo pipefail

echo "=== NixOS Configuration Installer ==="
echo ""

# Get username
read -p "Enter username (default: nixos): " USERNAME
USERNAME=${USERNAME:-nixos}

# Remove any whitespace
USERNAME=$(echo "$USERNAME" | tr -d '[:space:]')

# Validate username format
if ! echo "$USERNAME" | grep -qE '^[a-z_][a-z0-9_-]*$'; then
    echo "Error: Invalid username format. Username must start with a lowercase letter or underscore,"
    echo "and can only contain lowercase letters, numbers, underscores, and hyphens."
    exit 1
fi

echo "Username: ${USERNAME}"
echo ""

# Get full name
read -p "Enter full name (default: ${USERNAME}): " FULLNAME
FULLNAME=${FULLNAME:-$USERNAME}
echo ""

# Get hostname
read -p "Enter hostname (default: nixos-desktop): " HOSTNAME
HOSTNAME=${HOSTNAME:-nixos-desktop}

# Remove any whitespace
HOSTNAME=$(echo "$HOSTNAME" | tr -d '[:space:]')

# Validate hostname format
if ! echo "$HOSTNAME" | grep -qE '^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$'; then
    echo "Error: Invalid hostname format. Hostname must contain only lowercase letters, numbers, and hyphens,"
    echo "and cannot start or end with a hyphen."
    exit 1
fi

echo "Hostname: ${HOSTNAME}"
echo ""

# Get password
while true; do
    read -s -p "Enter password for ${USERNAME}: " PASSWORD
    echo ""
    read -s -p "Confirm password: " PASSWORD_CONFIRM
    echo ""

    if [ "$PASSWORD" = "$PASSWORD_CONFIRM" ]; then
        if [ -z "$PASSWORD" ]; then
            echo "Error: Password cannot be empty. Please try again."
            echo ""
        else
            break
        fi
    else
        echo "Error: Passwords do not match. Please try again."
        echo ""
    fi
done

echo ""
echo "User information collected. Starting installation with sudo..."
echo ""

# Download the main install script and run it with sudo, passing all the info
curl -sL https://raw.githubusercontent.com/votex09/nixos/main/tools/install.sh | \
    sudo bash -s -- "${USERNAME}" "${PASSWORD}" "${FULLNAME}" "${HOSTNAME}"
