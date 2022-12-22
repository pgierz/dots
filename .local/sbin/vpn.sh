#!/bin/bash
# ================================================================================  
# Provides a quick-access CLI interface for Cisco Anyconnect and any VPN binary 
# which provides the `connect` and `disconnect` subcommands. 
# 
# Usage:
# ------
# $ vpn on  # Will connect to ${VPN_SERVER} 
# $ vpn off  # Will disconnect to ${VPN_SERVER}
#
# Arguments:
# ----------
# $1 :
#   `on` or `off` to disconnect or disconnect.
#
# Optional Files:
# ---------------
# ${PASSWORD_INFO_FILE} :
#   This file contains user name and password information. Defaults to
#   ${HOME}/.config/cisco/login_info.txt 
#
# Environment Variables:
# ----------------------
# ${VPN_BIN} :
#   Location of the vpn program to use (e.g. Cisco Anyconnect) Defaults to
#   /opt/cisco/secureclient/bin/vpn
# ${VPN_SERVER} :
#   The server to connect to. Defaults to vpn.awi.de
# ${PASSWORD_INFO_FILE} :
#   File with username and password information in the following format:
#
#   $ cat ${PASSWORD_INFO_FILE}
#   <user_name>
#   <password>
#   
#   Defaults to ${HOME}/.config/cisco/login_info.txt, each entry should 
#   be on a separate line.
#
#   If such a file is not available, tries to use the ${HOME}/.netrc file
#
# Paul Gierz, December 2022
# ================================================================================  
VPN_BIN=${VPN_BIN:-/opt/cisco/secureclient/bin/vpn}
VPN_SERVER=${VPN_SERVER:-vpn.awi.de}
PASSWORD_INFO_FILE=${PASSWORD_INFO_FILE:-~/.config/cisco/login_info.txt}
if [ -f "${PASSWORD_INFO_FILE}" ]; then
  read -r -d '\n' USERNAME PASSWORD < "${PASSWORD_INFO_FILE}"
else
  USERNAME=$(python -c "import netrc; nrcs = netrc.netrc(); print(nrcs.hosts[${VPN_SERVER}][0])")
  PASSWORD=$(python -c "import netrc; nrcs = netrc.netrc(); print(nrcs.hosts[${VPN_SERVER}][-1])")
fi
temp_file=$(mktemp)
echo "${USERNAME}" >> "${temp_file}"
echo "${PASSWORD}" >> "${temp_file}"
echo "y" >> "${temp_file}"
case $1 in
  on)
    ${VPN_BIN} -s connect "${VPN_SERVER}" < "${temp_file}"
    rm "${temp_file}"
    ;;
  test)
    cat "${temp_file}"
    rm "${temp_file}"
    ;;
  off)
    ${VPN_BIN} -s disconnect "${VPN_SERVER}"
    ;;
  *)
    echo "Please use the subcommand on or off!"
    exit 1
    ;;
esac
