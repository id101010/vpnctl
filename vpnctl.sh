#!/bin/bash

OVPNCFG="******"
VPNCCFG="******"
PIDPATH="/var/run/vpn/"
PIDFILE="pid"
OPTION="${1}"

# ------------------------------------  Functions

usage()
{
cat << EOF
Usage: $0 [options]

This script is intended as an interface to multiple VPN services.

OPTIONS:
   help                 Show this message
   start [profile]      Connect to a ciscovpn or openvpn
   stop                 Kill all vpn connections
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

# Prints the current ip
print_ip()
{
    sleep 4 && IP=$(curl icanhazip.com 2>/dev/null)
    echo "[DEBUG] current ip: ${IP}" 2>&1
}

# Check if pid path exists
check_pid_path()
{
    if [[ -d ${PIDPATH} ]]
    then
        echo "[DEBUG] Writing PID file to ${PIDPATH}${PIDFILE}" 2>&1
    else
        mkdir ${PIDPATH}
    fi
}

# Connects to a openvpn vpn
connect_openvpn()
{
    check_pid_path
    cd "/etc/openvpn/" && openvpn --config "$OVPNCFG" --writepid "${PIDPATH}${PIDFILE}" --daemon
    
}

# Connects to a cisco 3000 vpn
connect_cisco()
{
    check_pid_path
    vpnc --pid-file "${PIDPATH}${PIDFILE}" ${VPNCCFG}
}

# Kill all vpn services.
kill_connection()
{
    kill $(cat ${PIDPATH}${PIDFILE})
}

# ----------------------------------------

# Option parsing
case ${OPTION} in
    start)
        check_root
        shift

        if [[ ${1} == "openvpn" ]]
        then
            echo "[DEBUG] Connecting to openvpn server."
            connect_openvpn
            print_ip
            exit 0
        fi
        
        if [[ ${1} == "cisco" ]]
        then
            echo "[DEBUG] Connecting to cisco vpn."
            connect_cisco
            print_ip
            exit 0
        fi

        echo "[ERROR] No profile specified!"

        exit 1
    ;;
    stop)
        check_root
        echo "[DEBUG] Killing all vpn connections."
        kill_connection
        exit 0
    ;;
    help)
        usage
        exit 0
    ;;
    *)
        echo "[ERROR] Unknown parameters."
        usage
        exit 1
    ;;
esac
