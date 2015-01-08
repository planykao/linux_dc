#!/bin/sh
#
# check hdd sequence by uuid
#

# variables
CONF="hdd_seq.conf"
LOG="hdd_seq.log"
FAIL=0
TIMES=0

# functions
compare_uuid() {
	if [ $1 != $2 ]; then
		echo UUID mismatch
		exit 1
	fi
}

get_uuid() {
	SYS_UUID=`blkid /dev/$1 | awk '{print $2}' | sed s/UUID=//g | sed s/\"//g`
}

# check environment
if ! type "blkid" > /dev/null 2>&1; then
	echo blkid: command not found
	exit 1
fi

# devices
DEVS="sda1 sdb1 sdc1 sdd1 sde1 sdf1 sdg1 sdh1 sdi1 sdj1 sdk1 sdl1 sdm1 sdn1 sdo1 sdp1 sdq1 sdr1 sds1 sdt1 sdu1 sdv1 sdw1 sdx1 sdy1 sdz1"

# check configuration
if [ -f "hdd_seq.conf" ]; then
	TIMES=`cat $CONF | grep TIMES | awk '{print $2}'`
	for i in $DEVS
	do
		if ls /dev/$i > /dev/null 2>&1; then
			CONF_UUID=`cat $CONF | grep $i | awk '{print $2}'`
			get_uuid $i
			if [ $SYS_UUID != $CONF_UUID ]; then
				FAIL=1
			fi
			echo "$i $SYS_UUID" >> $CONF
		else
			DEV=`cat $CONF | grep $i`
			if [ -n "$DEV" ]; then
				FAIL=1
			fi
		fi
	done
fi

# write current UUID to configuration file
echo "TIMES $(($TIMES + 1))" > $CONF
for i in $DEVS
do
	if ls /dev/$i > /dev/null 2>&1; then
		get_uuid $i
		echo "/dev/$i $SYS_UUID"
		echo "$i $SYS_UUID" >> $CONF
	fi
done

if [ $FAIL -eq 1 ]; then
	echo "$(($TIMES + 1))" >> $LOG
fi
