WAN_EXT_IP="98.137.246.7"
WAN_EXT_HOST="google.com"
UP_TEXT="UP"
DOWN_TEXT="DOWN"
FORMAT1="\e[4;32m"
FORMAT1a="\e[32m"
FORMAT2="\e[4;31m"
FORMAT2a="\e[31m"
FORMAT3="\e[1;34m"
FORMAT4="\e[90m"
CLRFMT="\e[0m"
HEADER_TEXT1="  =="
HEADER_TEXT2="==  "
ROUTER_INT_IP="192.168.0.30"
MODEM_INT_IP="192.168.100.1"
FUNCTIONAL_TEXT="All equipment operational"
PROBLEMS_TEXT="Some equipment non-functional"
CRIT_IT="Critical infrastructure "
FUNCTIONAL_CRIT_TEXT="$CRIT_IT$FORMAT1$UP_TEXT$CLRFMT$FORMAT1a"
PROBLEMS_CRIT_TEXT="$CRIT_IT$FORMAT2$DOWN_TEXT$CLRFMT$FORMAT2a"


FAILURE="0"
CRIT_FAILURE="0"



function _test {
if ping -q -c 1 -W 1 $1 >/dev/null; then
  printf '%b' "$FORMAT1a$2$CLRFMT  "
else
  printf '%b' "$FORMAT2a$2$CLRFMT  "
  FAILURE="1"
fi
}

function _test_crit {
if ping -q -c 1 -W 1 $1 >/dev/null; then
  printf '%b' "$FORMAT1$2$CLRFMT  "
else
  printf '%b' "$FORMAT2$2$CLRFMT  "
  CRIT_FAILURE="1"
  FAILURE="1"
fi
}

function _header {
if [ "$2" != "0" ]; then
  printf '%b\n\n'
else
  _intro
fi

printf '%b\n' "$FORMAT4$HEADER_TEXT1$FORMAT3$1$CLRFMT$FORMAT4$HEADER_TEXT2"
}

function _header2 {
if [ "$3" != "0" ]; then
  printf '%b\n'
else
  _intro
fi

printf '%b' "$2$FORMAT4$FORMAT3$1$CLRFMT$FORMAT4 - "
}


function _device {
printf "$2\e[4;90m$1$CLRFMT: "
}

function center {
  termwidth="$(tput cols)"
  padding="$(printf '%0.1s' ' '{1..500})"
  printf '%*.*s %b %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}

function _ip {
result=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
echo $result
}

function _intro {
clear
#printf ' --- Network check utility v2.0 --- \n'
printf 'Current IP: '
_ip
echo && echo
}

_header2 Internet "      " 0
_test_crit $WAN_EXT_IP WAN
_test_crit $WAN_EXT_HOST DNS

_header2 Infrastructure
_test_crit $MODEM_INT_IP Modem
_test_crit $ROUTER_INT_IP Router
_test_crit 192.168.0.31 pi
_test 192.168.0.200 NAS

_header2 Switches "      "
_test 192.168.0.10 *.10 #- not connected
_test_crit 192.168.0.11 *.11
_test_crit 192.168.0.12 *.12

echo

if [ "$CRIT_FAILURE" -eq 0 ]; then 
  printf '%b' "\n $FORMAT4$HEADER_TEXT1$FORMAT1a$HEADER_TEXT2$FUNCTIONAL_CRIT_TEXT$HEADER_TEXT1$FORMAT4$HEADER_TEXT2$CLRFMT"; 
else 
  printf '%b' "\n $FORMAT4$HEADER_TEXT1$FORMAT2a$HEADER_TEXT2$PROBLEMS_CRIT_TEXT$HEADER_TEXT1$FORMAT4$HEADER_TEXT2$CLRFMT"; 
fi

_header Computers
_device "Mac Pro" "  "
_test 192.168.0.201 "eth0"
_test 192.168.0.202 "eth1"
echo
_device "Xserve" "   "
_test 192.168.0.211 "eth0"
_test 192.168.0.212 "eth1"
echo
_device "GamingPC" " "
_test 192.168.0.203 "eth0"
_test 192.168.0.204 "eth1"


_header "Airport Nodes"
_test 192.168.0.35 Bedroom
_test 192.168.0.36 Bookcase
_test 192.168.0.37 Desk

_header Wireless
_test 192.168.0.99 iPhone6S+
_test 192.168.0.111 Netbook

echo

if [ "$FAILURE" -eq 0 ]; then 
  printf '%b\n\n' "\n $FORMAT4$HEADER_TEXT1$FORMAT1a$HEADER_TEXT2$FUNCTIONAL_TEXT$HEADER_TEXT1$FORMAT4$HEADER_TEXT2$CLRFMT"; 
else 
  printf '%b\n\n' "\n $FORMAT4$HEADER_TEXT1$FORMAT2a$HEADER_TEXT2$PROBLEMS_TEXT$HEADER_TEXT1$FORMAT4$HEADER_TEXT2$CLRFMT"; 
fi
