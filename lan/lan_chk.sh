#!/bin/sh

FAIL=0
BG_COLOR=44
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
	FAIL=1
else
	echo "$TIMES, LAN check PASS" >> $LOG
fi

if [ $FAIL -eq 1 ]; then
	BG_COLOR=41
fi

printf "\e[1;30;47m%-40s\e[0m\n" "LAN Check"
printf "\e[37;44m%-20s%-20s\e[0m\n" "DEFAULT" "$LAN_CONF"
printf "\e[37;44m%-20s\e[37;${BG_COLOR}m%-20s\e[0m\n" "SYSTEM" "$LAN_SYS"

