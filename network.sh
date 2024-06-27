#Network utility that verifies connectivity - should be run in a loop every few seconds 
#		sleep 2 && while true; do /Users/you/network.sh -critonly ; sleep 2; done
#		sleep 2 && while true; do /Users/you/network.sh ; sleep 2; done



#############################################
################# Constants #################
#############################################

CRIT_ONLY_FLAG="-critonly"

WAN_EXT_IP="142.250.72.78"
WAN_EXT_HOST="google.com"
ROUTER_INT_IP="10.0.0.1"
#MODEM_INT_IP="192.168.100.1" #in case your router/modem has a second login interface at a different IP

FORMAT1="\e[4;32m"
FORMAT1a="\e[32m"
FORMAT2="\e[4;31m"
FORMAT2a="\e[31m"
FORMAT3="\e[1;34m"
FORMAT4="\e[90m"
CLRFMT="\e[0m"

CRIT_IT="Critical infrastructure "
UP_TEXT="UP"
DOWN_TEXT="DOWN"

FUNCTIONAL_TEXT="All equipment operational"
PROBLEMS_TEXT="Some equipment inactive"

HEADER_TEXT1="  ========"
HEADER_TEXT2="========  "
HEADER_TEXT3=" └"
HEADER_TEXT4=": "

FUNCTIONAL_CRIT_TEXT="$CRIT_IT$FORMAT1$UP_TEXT$CLRFMT$FORMAT1a"
PROBLEMS_CRIT_TEXT="$CRIT_IT$FORMAT2$DOWN_TEXT$CLRFMT$FORMAT2a"






#############################################
################# Variables #################
#############################################

FAILURE="0"
CRIT_FAILURE="0"






#############################################
################# Functions #################
#############################################

function _test {
  if [ "$3" = $CRIT_ONLY_FLAG ]; then
    : #dont want to process this non critical test if we are in crit only mode
  else
    if ping -q -c 1 -W 1 $1 >/dev/null; then
      printf '%b' "$FORMAT1a$2$CLRFMT  "
    else
      printf '%b' "$FORMAT2a$2$CLRFMT  "
      FAILURE="1"
    fi
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

printf '%b\n' "$FORMAT4$HEADER_TEXT3$FORMAT3$1$CLRFMT$FORMAT4$HEADER_TEXT4"
}

function _header2 {
if [ "$3" != "0" ]; then
  printf '%b\n'
else
  _intro
fi

printf '%b' "$2$FORMAT4$FORMAT3$1$CLRFMT$FORMAT4: "
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
#printf ' --- Network check utility v3.0 --- \n'
printf 'Current IP: '
_ip
echo
}








#############################################
################# Handling #################
#############################################



if [ "$1" = $CRIT_ONLY_FLAG ]; then
  clear &&
  _header2 Internet "      "
else
  _header2 Internet "      " 0
fi



_test_crit $WAN_EXT_IP WAN
_test_crit $WAN_EXT_HOST DNS

_header2 Infrastructure 
#_test_crit $MODEM_INT_IP Modem
_test_crit $ROUTER_INT_IP Modem #Gateway
#_test_crit 192.168.0.29 Wi-Fi
_test 10.0.0.200 NAS $1
_test_crit 10.0.0.31 pi3B+
_test 10.0.0.32 pivm $1

_header2 Switches "      "
#_test 192.168.0.10 *.10
#_test_crit 192.168.0.11 *.11
#_test 192.168.0.12 *.12
#_test_crit 192.168.0.14 *.14
#_test_crit 192.168.0.15 *.15
#_test 192.168.0.16 *.16 $1
_test_crit 10.0.0.20 "Core_10Gb"
_test_crit 10.0.0.11 "\n\t\tCore_Ethernet"
_test 10.0.0.14 "\n\t\tEntertainment" $1
_test 10.0.0.15 "Downstairs_Office" $1
printf "\n\t\t"
_test 10.0.0.16 "Upstairs_Office#1" $1
_test 10.0.0.17 "Upstairs_Office#2" $1

echo

if [ "$CRIT_FAILURE" -eq 0 ]; then
  printf '%b' "\n $FORMAT4$HEADER_TEXT1$FORMAT1a$HEADER_TEXT2$FUNCTIONAL_CRIT_TEXT$HEADER_TEXT1$FORMAT4$HEADER_TEXT2$CLRFMT";
else
  printf '%b' "\n $FORMAT4$HEADER_TEXT1$FORMAT2a$HEADER_TEXT2$PROBLEMS_CRIT_TEXT$HEADER_TEXT1$FORMAT4$HEADER_TEXT2$CLRFMT";
fi


if [ "$1" = $CRIT_ONLY_FLAG ]; then
  echo && echo && exit
fi






_header Servers
_device "NUC" "         "
_test nuc.local "eth0"
echo
_device "Mac Pro" "     "
_test 10.0.0.201 "eth0"
#_test 192.168.0.202 "eth1"
#_device "Xserve" "   "
#_test 192.168.0.211 "eth0"
#_test 192.168.0.212 "eth1"
echo
_device "mini-serv" "   "
_test 10.0.0.210 "eth0"
#echo
#_device "netbook" "     "
#_test 192.168.0.131 "eth0"



_header Computers
_device "m1ni" "        "
_test 10.0.0.202 "eth0"
echo
_device "Aurora" "      "
_test aurora.local "eth0"
#echo
#_device "netbook" "     "
#_test 192.168.0.131 "eth0"



_header Laptops
#_device "Razer 14\"" "   "
#_test 10.0.0.202 "Connected"
#echo
_device "MacBook Pro" " "
_test macbook-pro.local "Connected"



_header AppleTV
_device "Bedroom" "     "
_test bedroom-tv.local eth0
echo
_device "Downstairs" "  "
_test living-room-tv.local eth0



_header "Airport Nodes"
_device "Bedroom" "     "
_test 10.0.0.35 eth0
echo
_device "Office" "      "
_test 10.0.0.36 eth0
echo
_device "Living Room" " "
_test 10.0.0.37 eth0



_header Wireless
_device "iPhone" "      "
_test tiphone.local "15 Pro Max"
#_test knowledavigator.local "12 Pro Max"
#_test iphone6s.local 6S+



#_header Wireless
#_test 192.168.0.99 iPhone6S+
#_test 192.168.0.111 Netbook



#_header Wireless
#_test 192.168.0.99 iPhone6S+
#_test 192.168.0.111 Netbook

echo

if [ "$FAILURE" -eq 0 ]; then
  printf '%b\n\n' "\n $FORMAT4$HEADER_TEXT1$FORMAT1a$HEADER_TEXT2$FUNCTIONAL_TEXT$HEADER_TEXT1$FORMAT4$HEADER_TEXT2$CLRFMT";
else
  printf '%b\n\n' "\n $FORMAT4$HEADER_TEXT1$FORMAT2a$HEADER_TEXT2$PROBLEMS_TEXT$HEADER_TEXT1$FORMAT4$HEADER_TEXT2$CLRFMT";
fi


