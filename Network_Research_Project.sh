#!/bin/bash

# Mission: Map network devices for port scanning and service enumeration

# Function to Validate the Network Range Input
function VLDT() {
    # Perform a list scan (-sL) to validate the range, redirect errors to .chk
    nmap $RNG -sL 2> .chk 1> .scan1   
    
    # Check if .chk contains any errors
    if [ ! -z "$(cat .chk)" ]; then 
        echo "[!] Wrong input, run again!"
        exit
    else 
        echo "[+] Range is correct, proceeding..."
    fi
}

# Function to Perform Basic Scan
function SCN1() {
    for IP in $(cat .scan1 | awk '{print $NF}' | grep ^[0-9]); do 
        echo "[*] Scanning $IP"
        nmap -sS -sU --version-all $IP > $DAT/$IP  # Perform TCP+UDP scan with service detection
    done
}

# Function to Perform Full Scan (NSE and Vulnerability Analysis)
function SCN2() {
    for IP in $(cat .scan1 | awk '{print $NF}' | grep ^[0-9]); do 
        echo "[*] Running full scan on $IP"
        nmap -sS -sU --script=vuln --version-all $IP > $DAT/$IP  # Perform vulnerability scanning
        searchsploit --nmap $DAT/$IP >> $DAT/$IP  # Append exploit search results
    done
}

# Ask the user to choose 'Basic' or 'Full'
read -p "[*] Choose [B]asic or [F]ull: " CHK

case $CHK in 
    B|b)
        echo "[+] You chose Basic mode."
        read -p "[?] Enter a range to scan (e.g., 192.168.1.0/24): " RNG
        VLDT  # Validate the input
        read -p "[+] Enter the name of the folder to save results: " DAT
        mkdir -p $DAT  # Create folder if it doesn’t exist
        SCN1  # Run basic scan
        ;;
    F|f)
        echo "[+] You chose Full mode."
        read -p "[?] Enter a range to scan (e.g., 192.168.1.0/24): " RNG
        VLDT  # Validate the input
        read -p "[+] Enter the name of the folder to save results: " DAT
        mkdir -p $DAT  # Create folder if it doesn’t exist
        SCN2  # Run full scan
        ;;
    *)
        echo "[!] Invalid choice. Exiting."
        exit 1
        ;;
esac

# Zip the results
zip -r ${DAT}.zip $DAT

echo "[+] Scan complete! Results are saved in $DAT and compressed in ${DAT}.zip"
