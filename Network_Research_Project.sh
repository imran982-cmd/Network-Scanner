#!/bin/bash

# Network Research Project: Remote Control
# Student: [Your Name], Code: [Your Student ID], Class Code: NX201
# Lecturer: [Your Lecturer's Name]

# Function to install required tools
function INSTALL() {
    echo "[*] Installing required tools..."
    for tool in nmap sshpass nipe torify whois; do
        if ! command -v $tool &> /dev/null; then
            sudo apt-get install -y $tool
        else
            echo "[*] $tool is already installed."
        fi
    done
}

# Function to check network anonymity
function ANON() {
    echo "[*] Checking anonymity..."
    IP=$(curl -s ifconfig.me)
    if geoiplookup $IP | grep -q "IL"; then
        echo "[!] You are NOT anonymous! Exiting..."
        exit 1
    else
        SPOOFED_COUNTRY=$(geoiplookup $IP | awk -F: '{print $2}')
        echo "[*] You are anonymous. Spoofed location: $SPOOFED_COUNTRY"
    fi
}

# Function to execute remote commands via SSH
function RMT() {
    echo "[*] Connecting to the remote server..."
    read -p "[*] Enter the remote server IP: " IP
    read -p "[*] Enter the remote server username: " USER
    read -sp "[*] Enter the remote server password: " PASS
    echo
    read -p "[*] Enter a domain to scan: " DMN

    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no $USER@$IP <<EOF
echo "Remote Server Info:"
echo "Country: $(geoiplookup $IP | awk -F: '{print $2}')"
echo "Uptime: $(uptime)"
whois $DMN > /tmp/${DMN}_whois.txt
nmap $DMN > /tmp/${DMN}_nmap.txt
EOF

    echo "[*] Files saved on the remote server: /tmp/${DMN}_whois.txt and /tmp/${DMN}_nmap.txt"
}

# Function to create a local log
function LOG() {
    local DOMAIN=$1
    echo "$(date) - Scanned domain: $DOMAIN" >> NR.log
}

# Main script execution
echo "[*] Starting Network Research Project..."
INSTALL
ANON
RMT
LOG $DMN
echo "[*] Project completed. Check NR.log for details."
