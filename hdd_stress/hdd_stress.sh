#!/bin/sh

HDD_SEQ_LOG="hdd_seq.log"
HDD_PARM_LOG="hdparm.log"

time_elapse() {
	CURRENT_TIME=`date +%s`
	ELAPSE_SEC=$((CURRENT_TIME - BEGIN_TIME))
	HOUR=$((ELAPSE_SEC / 3600))
	MIN=$(($((ELAPSE_SEC - $((HOUR * 3600)))) / 60))
	SEC=$(($((ELAPSE_SEC - $((HOUR * 3600)))) % 60))
#	echo "        $HOUR:$MIN:$SEC elapsed."
}

BEGIN_TIME=`date +%s`

while [ 1 ]; do
	# check hdd sequence
	sh hdd_seq.sh $BEGIN_TIME
	time_elapse

	# run hdparm
	sh hdparm.sh $BEGIN_TIME
	time_elapse

	echo "<<Total elapsed time: $HOUR:$MIN:$SEC>>"
	echo ""
done
