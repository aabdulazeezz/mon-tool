#!/bin/bash

LOGL=${1}
BOT_T=7736798404:AAErTZNPmINv0N6oKTTi9NhvoB-VhY8QVzM
INTERVAL=3 #time interval of sending ALARM message
CPULIM=30
CHID=-1002426192906
n_cpuc=$(nproc)
cpu_alarm=0
cpu_peak=0
cpu_peak_lim=5
while (true); do
	datetime=$(date)
	cpu_oload=$(uptime | awk '{print $(NF-2)}' | tr -d ',.')
	cpu_load_p=$( echo "$cpu_oload / $n_cpuc" | bc )

if [[ $cpu_load_p -ge $CPULIM && $cpu_alarm -eq 0 ]]; then
	if [[ $LOGL == error ]]; then
        	echo "$datetime | CPU load%: $cpu_load_p" >> /home/ubuser/mon-tool/cpu.log
	fi
	cpu_peak=$(($cpu_peak+1))
	if [[ $cpu_peak -ge $cpu_peak_lim ]]; then
		curl -s -X POST https://api.telegram.org/bot${BOT_T}/sendMessage -d chat_id=${CHID} -d text="🔥Alarm %0A%0ACPU load %: $cpu_load_p" > /dev/null 2>&1
		cpu_alarm=1
		cpu_peak=0
	fi
fi	

if [[ $cpu_load_p -lt $CPULIM && $cpu_alarm -eq 1 ]]; then
	curl -s -X POST https://api.telegram.org/bot${BOT_T}/sendMessage -d chat_id=${CHID} -d text="Resolved✅ %0A%0ACPU load %: $cpu_load_p" > /dev/null 2>&1
	cpu_alarm=0
fi

if [[ $LOGL == debug ]]; then
	echo "$datetime | CPU load%: $cpu_load_p" >> /home/ubuser/mon-tool/cpu.log
fi

sleep $INTERVAL
done
