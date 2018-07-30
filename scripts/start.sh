#!/bin/bash

function addhost() {

    HOSTNAME_VALUE=$1
    IP_VALUE=$2
    ETC_HOSTS="/etc/hosts"
    HOSTS_LINE="$IP_VALUE   $HOSTNAME_VALUE"

    local HOST_REGEX="\(\s\+\)${HOSTNAME_VALUE}\s*$"

    result=$(grep "$HOST_REGEX" /etc/hosts)

    if [ "$result" ]; 
       then
        echo "Entry already exists !"                    
       else
            echo "Adding : $HOSTS_LINE to /etc/hosts"                       
            echo "$HOSTS_LINE" >> /etc/hosts     
     fi
}

addhost "kafka" "192.168.2.38"

/opt/splunk-kafka-connect/bin/connect-distributed.sh  /opt/splunk-kafka-connect/config/connect-quickstart.properties

