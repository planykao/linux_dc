#!/bin/sh
#
# check hdd sequence by uuid
#

# variables
CONF="hdd_seq.conf"
LOG="hdd_seq.log"
TMP="hdd_seq.tmp"
FAIL=0
TOTAL_FAIL=0
TIMES=0

# functions
get_uuid() {
	SYS_UUID=`blkid -s UUID /dev/$1 | awk '{print $2}' | sed s/UUID=//g | sed s/\"//g`
}

get_model() {
	DEV="`echo $1 | sed 's/[0-9]*//g'`"
	SYS_MODEL=`hdparm -i /dev/$DEV | grep Model | cut -d',' -f1 | sed 's/ Model=//g'`
}

string_compare() {
	if [ "$1" != "$2" ]; then
		FAIL=1
	fi
}

time_elapse() {
	CURRENT_TIME=`date +%s`
	ELAPSE_SEC=$((CURRENT_TIME - BEGIN_TIME))
	HOUR=$((ELAPSE_SEC / 3600))
	MIN=$(($((ELAPSE_SEC - $((HOUR * 3600)))) / 60))
	SEC=$(($((ELAPSE_SEC - $((HOUR * 3600)))) % 60))
#	echo "        $HOUR:$MIN:$SEC elapsed."
}

# check environment
if ! type "blkid" > /dev/null 2>&1; then
	echo "blkid: command not found"
	exit 1
fi

# devices
DEVS="sda1 sdb1 sdc1 sdd1 sde1 sdf1 sdg1 sdh1 sdi1 sdj1 sdk1 sdl1 sdm1 sdn1 sdo1 sdp1 sdq1 sdr1 sds1 sdt1 sdu1 sdv1 sdw1 sdx1 sdy1 sdz1"

#BEGIN_TIME=`date +%s`
BEGIN_TIME=$1
DATE=`date`

# check configuration
if [ -f "hdd_seq.conf" ]; then
	TIMES=`cat $CONF | grep TIMES | awk '{print $2}'`
	TIMES=$((TIMES + 1))
	TOTAL_FAIL=`cat $CONF | grep TOTAL_FAIL | awk '{print $2}'`

	echo "TIMES $TIMES" > $TMP
	echo "Times: $TIMES, start @ $DATE" >> $LOG
	echo "Times: $TIMES, start @ $DATE"

	for i in $DEVS
	do
		if ls /dev/$i > /dev/null 2>&1; then
			CONF_UUID="`cat $CONF | grep $i | cut -d',' -f2`"
			CONF_MODEL="`cat $CONF | grep $i | cut -d',' -f3`"
			get_uuid $i
			string_compare "$CONF_UUID" "$SYS_UUID"
			get_model $i
			string_compare "$CONF_MODEL" "$SYS_MODEL"
		
			echo " $i,$SYS_UUID,$SYS_MODEL"
			echo " $i,$SYS_UUID,$SYS_MODEL" >> $TMP
			echo " $i,$SYS_UUID,$SYS_MODEL" >> $LOG
		else # can't find device in configuration file
			DEV=`cat $CONF | grep $i`
			if [ -n "$DEV" ]; then
				FAIL=1
			fi
		fi
	done

	# update the configuration file
	mv $TMP $CONF > /dev/null 2>&1
else
# write current UUID and MODEL to configuration file
	TIMES=$((TIMES + 1))
	echo "Times: $TIMES, start @ $DATE"
	echo "Times: $TIMES, start @ $DATE" > $LOG
	echo "TIMES $TIMES" > $CONF

	for i in $DEVS
	do
		if ls /dev/$i > /dev/null 2>&1; then
			get_uuid $i
			get_model $i
			echo " /dev/$i,$SYS_UUID,$SYS_MODEL"
			echo " $i,$SYS_UUID,$SYS_MODEL" >> $CONF
			echo " $i,$SYS_UUID,$SYS_MODEL" >> $LOG
		fi
	done
fi

# write log
if [ $FAIL -eq 1 ]; then
	echo "    Result: FAIL"
	echo "    Result: FAIL" >> $LOG
	FAIL=0
	TOTAL_FAIL=$((TOTAL_FAIL + 1))
else
	echo "    Result: PASS"
	echo "    Result: PASS" >> $LOG
fi

time_elapse

echo "      [Total Times: $TIMES, Total Fail: $TOTAL_FAIL, $HOUR:$MIN:$SEC elapsed.]"
echo "      [Total Times: $TIMES, Total Fail: $TOTAL_FAIL, $HOUR:$MIN:$SEC elapsed.]" >> $LOG
echo "TOTAL_FAIL $TOTAL_FAIL" >> $CONF

echo ""
echo "" >> $LOG

