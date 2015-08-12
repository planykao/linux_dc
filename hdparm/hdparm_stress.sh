#!/bin/sh

HDPARM_CONF="hdparm.conf"
HDPARM_LOG="hdparm.log"
HDPARM_RESULT="hdparm_result.log"
HDPARM_RESULT_TMP="hdparm_result.tmp"
CACHED_FAIL=0
FAIL=0
BUFFERED_FAIL=0

# devices
#DEVS="sda sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz"
DEVS=(sda sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz)

read_config() {
	if [ -f $HDPARM_CONF ]; then
		TIMES=`cat $HDPARM_CONF | grep TIMES | awk '{print $2}'`
		TOTAL_FAIL=`cat $HDPARM_CONF | grep TOTAL_FAIL | awk '{print $2}'`
		BUFFERED=(`cat $HDPARM_CONF | grep BUFFERED | cut -d' ' -f2-`)
	else
		echo "No such file, please make sure \"$HDPARM_CONF\" is exist."
		exit 1
	fi
}

write_config() {
	echo "TIMES $TIMES" > $HDPARM_CONF
	echo "TOTAL_FAIL $TOTAL_FAIL" >> $HDPARM_CONF
	echo -n "BUFFERED" >> $HDPARM_CONF
	for ((i=0; i<${#BUFFERED[@]}; i++)); do
		echo -n " " >> $HDPARM_CONF
		echo -n ${BUFFERED[$i]} >> $HDPARM_CONF
	done
	echo "" >> $HDPARM_CONF
}

time_elapse() {
	CURRENT_TIME=`date +%s`
	ELAPSE_SEC=$((CURRENT_TIME - BEGIN_TIME))
	HOUR=$((ELAPSE_SEC / 3600))
	MIN=$(($((ELAPSE_SEC - $((HOUR * 3600)))) / 60))
	SEC=$(($((ELAPSE_SEC - $((HOUR * 3600)))) % 60))
#	echo "        $HOUR:$MIN:$SEC elapsed."
}

minimum() { # $1 = device name, $2 = value
	if [ -f $HDPARM_RESULT ]; then
		CUR_MIN=`cat $HDPARM_RESULT | grep $1 | awk '{print $3}'`
		if [ $CUR_MIN -lt $2 ]; then
			MIN=$CUR_MIN
		else
			MIN=$2
		fi
	else
		MIN=$2
	fi
}

maximum() { # $1 = device name, $2 = value
	if [ -f $HDPARM_RESULT ]; then
		CUR_MAX=`cat $HDPARM_RESULT | grep $1 | awk '{print $2}'`
		if [ $CUR_MAX -gt $2 ]; then
			MAX=$CUR_MAX
		else
			MAX=$2
		fi
	else
		MAX=$2
	fi
}

# devices
#DEVS="sda sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz"
DEVS=(sda sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz)

BEGIN_TIME=`date +%s`

while [ 1 ]; do
	# read configuration
	read_config
	TIMES=$(($TIMES + 1))

	DATE="`date`"
	echo "Times: $TIMES, start @ $DATE"
	echo "Times: $TIMES, start @ $DATE" >> $HDPARM_LOG
	echo "# Devies MAX MIN" > $HDPARM_RESULT_TMP

	# hdaprm test
	for ((i=0; i<${#DEVS[@]}; i++)); do
		if ls /dev/${DEVS[$i]} > /dev/null 2>&1; then
			echo " /dev/${DEVS[$i]}:"
			echo " /dev/${DEVS[$i]}:" >> $HDPARM_LOG

			BUFFERED_RESULT=`hdparm -t /dev/${DEVS[$i]} | grep buffered | awk '{print $11}' | cut -d'.' -f1 2>&1`
			minimum ${DEVS[$i]} $BUFFERED_RESULT
			maximum ${DEVS[$i]} $BUFFERED_RESULT
			echo "${DEVS[$i]} $MAX $MIN" >> $HDPARM_RESULT_TMP
			
			if [ $BUFFERED_RESULT -lt ${BUFFERED[$i]} ]; then
				FAIL=1
				BUFFERED_FAIL=1
			fi

			if [ $BUFFERED_FAIL -eq 0 ]; then
				echo "    Timing buffered disk reads: $BUFFERED_RESULT(${BUFFERED[$i]}), PASS"
				echo "    Timing buffered disk reads: $BUFFERED_RESULT(${BUFFERED[$i]}), PASS" >> $HDPARM_LOG
			else
				echo "    Timing buffered disk reads: $BUFFERED_RESULT(${BUFFERED[$i]}), FAIL"
				echo "    Timing buffered disk reads: $BUFFERED_RESULT(${BUFFERED[$i]}), FAIL" >> $HDPARM_LOG
			fi
		else
#			echo "No such device: $i, test finished."
			break
		fi

		BUFFERED_FAIL=0
	done

	if [ $FAIL -eq 1 ]; then
		FAIL=0
		TOTAL_FAIL=$((TOTAL_FAIL + 1))
	fi

	write_config
	# save tmp file to result
	mv $HDPARM_RESULT_TMP $HDPARM_RESULT 2>&1

	time_elapse
	
	echo "      [Total Times: $TIMES, Total Fail: $TOTAL_FAIL, $HOUR:$MIN:$SEC elapsed.]"
	echo "      [Total Times: $TIMES, Total Fail: $TOTAL_FAIL, $HOUR:$MIN:$SEC elapsed.]" >> $HDPARM_LOG
	echo ""
	echo "" >> $HDPARM_LOG
done
