#!/bin/sh

LOG="lan_chk.log"
CONF="lan_chk.conf"

if [ ! -f "$CONF" ]; then
	echo "$CONF, No such file."
	exit 1
fi

TIMES=`cat "$CONF" | grep TIMES | awk '{print $2}'`
TIMES=$((TIMES + 1))
LAN_CONF=`cat "$CONF" | grep LAN | awk '{print $2}'`

# write configuration file back
echo "TIMES $TIMES" > $CONF
echo "LAN $LAN_CONF" >> $CONF

LAN_SYS=`ifconfig -a | grep HWaddr | wc -l`

if [ $LAN_CONF -ne $LAN_SYS ]; then
	echo "$TIMES, LAN check FAIL: $LAN_SYS" >> $LOG
else
	echo "$TIMES, LAN check PASS" >> $LOG
fi

