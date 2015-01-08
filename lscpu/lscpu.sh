#!/bin/sh
#
# compare cpu sockets, cores and frequency
#

# BG color
SYS_CPU_BG=44
SYS_CORE_BG=44
SYS_FREQ_BG=44

# variable
FAIL=0
CONF=lscpu.conf
LOG=lscpu.log

# check environment
if ! type "lscpu" > /dev/null 2>&1; then
	echo lscpu: command not found
	exit 1
fi

if ! type "dmidecode" > /dev/null 2>&1; then
	echo dmidecode: command not found
fi

# check configuration file
if [ -f "$CONF" ]; then
	TIMES=`cat $CONF | grep TIMES | awk '{print $2}'`
	CONF_CPU=`cat $CONF | grep CPU | awk '{print $2}'`
	CONF_CORE=`cat $CONF | grep CORE | awk '{print $2}'`
	CONF_FREQ=`cat $CONF | grep FREQ | awk '{print $2}'`
else
	echo "$CONF: file not found"
	exit 1
fi

# write configuration back
echo "TIMES $(($TIMES + 1))" > $CONF
echo "CPU $CONF_CPU" >> $CONF
echo "CORE $CONF_CORE" >> $CONF
echo "FREQ $CONF_FREQ" >> $CONF

# get system information
SYS_CPU=`lscpu | grep Socket | awk '{print $2}'`
SYS_CORE=`lscpu | grep "CPU(s):" | grep -v NUMA | awk '{print $2}'`
SYS_FREQ=`dmidecode -t processor | grep GHz | awk '{print $NF}' | sed s/GHz//g | sed -n '1p'`

# dump conf
printf "\e[1;30;47m%-60s\e[0m\n" "DEFAULT"
printf "\e[37;44m%-20s%-20s%-20s\e[0m\n" "CPU(s)" "Core(s)" "Freq.(GHz)"
printf "\e[37;44m%-20s%-20s%-20s\e[0m\n" "$CONF_CPU" "$CONF_CORE" "$CONF_FREQ"
printf ""

# set the bg color
if [ $CONF_CPU != $SYS_CPU ]; then
		SYS_CPU_BG=41
		FAIL=1
fi

if [ $CONF_CORE != $SYS_CORE ]; then
		SYS_CORE_BG=41
		FAIL=1
fi

if [ $CONF_FREQ != $SYS_FREQ ]; then
		SYS_FREQ_BG=41
		FAIL=1
fi

printf "\e[1;30;47m%-60s\e[0m\n" "SYSTEM"
printf "\e[37;44m%-20s%-20s%-20s\e[0m\n" "CPU(s)" "Core(s)" "Freq.(GHz)"
printf "\e[37;${SYS_CPU_BG}m%-20s\e[37;${SYS_CORE_BG}m%-20s\e[37;${SYS_FREQ_BG}m%-20s\e[0m\n" "$SYS_CPU" "$SYS_CORE" "$SYS_FREQ"

# write the system value to log file
if [ $FAIL -eq 1 ]; then
	if [ -f $LOG ]; then
		echo "$(($TIMES + 1)) $SYS_CPU $SYS_CORE $SYS_FREQ" >> $LOG
	else
		echo "# TIMES CPU(s) Core(s) Freq.(GHz)" > $LOG
		echo "$(($TIMES + 1)) $SYS_CPU $SYS_CORE $SYS_FREQ" >> $LOG
	fi
fi
