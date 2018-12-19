#!/bin/bash

# Configs
LOGDIR="./logs"

# Functions
function err_exception () {
 cat <<EOF > ${LOGDIR}/${UTIME}
ERR,${ERRSTR}
EOF
}

function termination () {
#  cat <<EOF > ${LOGDIR}/${UTIME}
  cat <<EOF > ${LOGDIR}/${MYIP}
UTIME,${UTIME}
DATE,${DATE}
DIG,${DIG}
MYIP,${MYIP}
EOF
}

function init () {
  if [ ! -d ${LOGDIR} ]; then
    mkdir ${LOGDIR}
  fi
}

function check () {
  init

  if [ ! "$#" = "1" ]; then
    return 1
  fi

  IP=$1
  echo "check $IP"

  UTIME=`date +%s`
  DATE=`date`

  sleep 2

  if [ ! "${IP}" = "" ]; then
    DIG=`dig @${IP} -t A ${FQDN} 2>/dev/null | grep -A 1 ";; ANSWER SECTION:" | tail -1`
    MYIP=$IP
  else
    DIG=""
    MYIP=$IP
  fi

  if [ "${DIG}" = "" ]; then
    echo "NG: $IP"
  fi

  termination
}

function main () {
  FQDN=$1
  while read line; do
    check ${line%%,*}
  done < ./dnslist.txt
}

# Main
if [ ! "$#" = "1" ]; then
  echo "check.sh <FQDM>"
  exit 1
fi

main $1
