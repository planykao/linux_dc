#!/bin/sh

HDPARM_CONF="hdparm.conf"
HDPARM_LOG="hdparm.log"
CACHED_FAIL=0
BUFFERED_FAIL=0

# devices
DEVS="sda sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy sdz"

# read configuration
if [ -f $HDPARM_CONF ]; then
	TIMES=`cat $HDPARM_CONF | grep TIMES | awk '{print $2}'`
	CACHED=`cat $HDPARM_CONF | grep CACHED | awk '{print $2}'`
	BUFFERED=`cat $HDPARM_CONF | grep BUFFERED | awk '{print $2}'`
	TIMES=$(($TIMES + 1))
	echo "TIMES $TIMES" > $HDPARM_CONF
	echo "CACHED $CACHED" >> $HDPARM_CONF
	echo "BUFFERED $BUFFERED" >> $HDPARM_CONF
else
	echo "No such file, please make sure \"$HDPARM_CONF\" is exist."
	exit 1
fi

# hdaprm test
echo "Times: $TIMES"
echo "Times: $TIMES" >> $HDPARM_LOG
for i in $DEVS
do
	if ls /dev/$i > /dev/null 2>&1; then
		CACHED_RESULT=`hdparm -T /dev/$i | grep cached | awk '{print $10}' 2>&1`
		BUFFERED_RESULT=`hdparm -t /dev/$i | grep buffered | awk '{print $11}' 2>&1`
		
		if [ `echo $CACHED_RESULT | cut -d'.' -f1` -lt $CACHED ]; then
			CACHED_FAIL=1
		fi

		if [ `echo $BUFFERED_RESULT | cut -d'.' -f1` -lt $BUFFERED ]; then
			BUFFERED_FAIL=1
		fi

		echo "/dev/$i:"
		if [ $CACHED_FAIL -eq 0 ]; then
			echo " Timing cached reads: $CACHED_RESULT, PASS"
			echo " Timing cached reads: $CACHED_RESULT, PASS" >> $HDPARM_LOG
		else
			echo " Timing cached reads: $CACHED_RESULT, FAIL"
			echo " Timing cached reads: $CACHED_RESULT, FAIL" >> $HDPARM_LOG
		fi

		if [ $BUFFERED_FAIL -eq 0 ]; then
			echo " Timing buffered disk reads: $BUFFERED_RESULT, PASS"
			echo " Timing buffered disk reads: $BUFFERED_RESULT, PASS" >> $HDPARM_LOG
		else
			echo " Timing buffered disk reads: $BUFFERED_RESULT, FAIL"
			echo " Timing buffered disk reads: $BUFFERED_RESULT, FAIL" >> $HDPARM_LOG
		fi

		echo ""
		echo "" >> $HDPARM_LOG
	else
		echo "No such device: $i, test finished."
		break
	fi
done

