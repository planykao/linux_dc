#!/bin/sh

CONF="ping.conf"
LOG="ping.log"

# read configuration

TIMES=`cat $CONF | grep TIMES | awk '{print $2}'`
DEV1=`cat $CONF | grep DEV1 | awk '{print $2}'`
DEV2=`cat $CONF | grep DEV2 | awk '{print $2}'`
DEST_IP1=`cat $CONF | grep DEST_IP1 | awk '{print $2}'`
DEST_IP2=`cat $CONF | grep DEST_IP2 | awk '{print $2}'`
SRC_IP1=`cat $CONF | grep SRC_IP1 | awk '{print $2}'`
SRC_IP2=`cat $CONF | grep SRC_IP2 | awk '{print $2}'`

COUNT=0

TIMES=$((TIMES + 1))
# write configuration back
echo "TIMES $TIMES" > $CONF
echo "DEV1 $DEV1" >> $CONF
echo "DEV2 $DEV2" >> $CONF
echo "DEST_IP1 $DEST_IP1" >> $CONF
echo "DEST_IP2 $DEST_IP2" >> $CONF
echo "SRC_IP1 $SRC_IP1" >> $CONF
echo "SRC_IP2 $SRC_IP2" >> $CONF

# main
#ifconfig $DEV1 $SRC_IP1 up
#ifconfig $DEV2 $SRC_IP2 up

while [ $COUNT -ne 20 ]
do
	ping $DEST_IP1 -c 1 -i 0.2 | grep ", 0% packet loss"
	
	if [ $? -ne 0 ]; then
		echo "$TIMES, $DEV1 PING FAIL." >> $LOG
		exit 1
	fi

	ping $DEST_IP2 -c 1 -i 0.2 | grep ", 0% packet loss"
	
	if [ $? -ne 0 ]; then
		echo "$TIMES, $DEV2 PING FAIL." >> $LOG
		exit 1
	fi

	COUNT=$((COUNT + 1))
done
