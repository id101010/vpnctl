#!/bin/bash

OVPNCFG="****"
VPNCCFG="****"
PIDPATH="/var/run/vpn/"
OPTION="${1}"

# ------------------------------------  Functions

usage()
{
cat << EOF
Usage: $0 [options]

This script is intended as an interface to multiple VPN services.

OPTIONS:
   -h --help            Show this message
   -c --cisco           Connect to a cisco vpn
   -o --openvpn         Connect to a openvpn server 
   -k --kill            Kill all vpn connections
EOF
}

# Check if root
check_root()
{
    if [[ $(id -u) -ne 0 ]]
    then
        echo "You are not root." 2>&1
        exit
    fi
}

# Check if pid path exists
check_pid_path()
{
    if [[ -d ${PIDPATH} ]]
    then
        echo "[DEBUG] Writing PID file to ${PIDPATH}pid" 2>&1
    else
        mkdir ${PIDPATH}
    fi
}

# Connects to a openvpn vpn
connect_openvpn()
{
    check_pid_path
    # Enable connection and check IP
    cd "/etc/openvpn/" && openvpn --config "$OVPNCFG" --writepid "${PIDPATH}pid" --daemon
    
    sleep 4 && IP=$(curl icanhazip.com 2>/dev/null)
    echo "[DEBUG] current ip: ${IP}" 2>&1
}

# Connects to a cisco 3000 vpn
connect_cisco()
{
    check_pid_path
    vpnc --pid-file "${PIDPATH}pid" ${VPNCCFG}
    
    IP=$(curl icanhazip.com 2>/dev/null)
    echo "[DEBUG] current ip: ${IP}" 2>&1
}

# Kill all vpn services.
kill_connection()
{
    killall openvpn 2>/dev/null
    killall vpnc 2>/dev/null
}

# ----------------------------------------

check_root

# Option Parsing
case ${OPTION} in
    -o|--openvpn)
    echo "[DEBUG] Connecting to openvpn server."
    connect_openvpn
    exit 0
    ;;
    -c|--cisco)
    echo "[DEBUG] Connecting to cisco vpn."
    connect_cisco
    exit 0
    ;;
    -k|--kill)
    echo "[DEBUG] Killing all vpn connections."
    kill_connection
    exit 0
    ;;
    -h|--help)
    usage
    exit 0
    ;;
    *)
    exit 1 # Unknown option
    ;;
esac
