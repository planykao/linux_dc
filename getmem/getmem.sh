#!/bin/sh
#
# get total physical memory
#

LOG="mem.log"
SYS_MEM=0

# read configuration file
TIMES=`cat $1 | grep TIMES | awk '{print $2}'`
CONF_MEM=`cat $1 | grep MEM | awk '{print $2}'`

# write configuration back
echo "TIMES $((TIMES + 1))" > $1
echo "MEM $CONF_MEM" >> $1

for i in `dmidecode -t 17 | grep Size: | grep -v "No Module" | sed s/Size://g | sed s/MB//g`
do
	SYS_MEM=$(($SYS_MEM + $i))
done

if [ $SYS_MEM -ne $CONF_MEM ]; then
	if [ -f $LOG ]; then
		echo "$(($TIMES + 1)) $SYS_MEM" >> $LOG
	else
		echo "# Times Memory" > $LOG
		echo "$(($TIMES + 1)) $SYS_MEM" >> $LOG
	fi
fi

echo "Total Memory: $SYS_MEM"
