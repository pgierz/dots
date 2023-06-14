#!/bin/bash
# ================================================================================  
# Provides a quick-access CLI interface for Cisco Anyconnect and any VPN binary
# which provides the `connect` and `disconnect` subcommands. This has **only**
# been tested on Cisco Anyconnect!
# 
# Usage:
# ------
# 
#     $ vpn.sh on   # Will connect to ${VPN_SERVER}
#     $ vpn.sh off  # Will disconnect to ${VPN_SERVER}
#     $ vpn.sh test # Will print to screen an example file with user credentials which would be piped to the ${VPN_BIN} program
# 
# Arguments:
# ----------
# ``$1`` : ``string``
# 
#     * ``on``, ``connect``: Establish the VPN connection
#     * `off``, ``disconnect``: Disconnect from the VPN connection
#     * ``test``: Determine if the file containing the user information and password is being correctly written.
# 
# Optional Files:
# ---------------
# ``# ${PASSWORD_INFO_FILE}`` :
# This file contains user name and password information. Defaults to
# ``${HOME}/.config/cisco/login_info.txt``. This can be set via environment
# variable, please see the next section.
# 
# Environment Variables:
# ----------------------
# ``${VPN_BIN}`` :
# 
#     Location of the vpn program to use (e.g. Cisco Anyconnect) Defaults to
# ``/opt/cisco/secureclient/bin/vpn``
# 
# ``${VPN_SERVER}`` :
# 
#     The server address to connect to. Defaults to vpn.awi.de
# 
# ``${PASSWORD_INFO_FILE}`` :
# 
#     File with username and password information in the following format::
# 
#         $ cat ${PASSWORD_INFO_FILE}
#         <user_name>
#         <password>
#         y
# 
#     Defaults to ``${XDG_CONFIG_HOME:=${HOME}/.config}/cisco/login_info.txt``, each entry should be on a separate line.
# 
#     Note that the final ``y`` in this file is "yes", to accept the security disclaimer automatically.
# 
#     If such a file is not available, tries to use the ``${HOME}/.netrc file``
# 
# Author:
# -------
# Paul Gierz, December 2022
# 
# ================================================================================  
VPN_BIN=${VPN_BIN:-/opt/cisco/secureclient/bin/vpn}
VPN_SERVER=${VPN_SERVER:-vpn.awi.de}
PASSWORD_INFO_FILE=${PASSWORD_INFO_FILE:-${XDG_CONFIG_HOME:=${HOME}/.config}/cisco/login_info.txt}
if [ -f "${PASSWORD_INFO_FILE}" ]; then
  read -r -d '\n' USERNAME PASSWORD < "${PASSWORD_INFO_FILE}"
else
  USERNAME=$(python -c "import netrc; nrcs = netrc.netrc(); print(nrcs.hosts['${VPN_SERVER}'][0])")
  PASSWORD=$(python -c "import netrc; nrcs = netrc.netrc(); print(nrcs.hosts['${VPN_SERVER}'][-1])")
fi
temp_file=$(mktemp)
echo -e "${USERNAME}\n${PASSWORD}\ny" >> "${temp_file}"
case $1 in
  on)
    ${VPN_BIN} -s connect "${VPN_SERVER}" < "${temp_file}"
    rm "${temp_file}"
    ;;
  off)
    ${VPN_BIN} -s disconnect "${VPN_SERVER}"
    ;;
  test)
    cat "${temp_file}"
    rm "${temp_file}"
    ;;
  *)
    echo "Please use the subcommand on or off!"
    exit 1
    ;;
esac
