#!/bin/bash
script_foder=$(dirname $(readlink -f "$0"))

source ${script_foder}/cpu.sh
source ${script_foder}/monitoring.conf

init(){
 if [[ ! -d ${script_foder}/states ]]; then
  	mkdir states
 fi
 touch  states/running
}

init

while [[ -f ${script_foder}/states/running ]]; do
 cpu_check
 sleep $INTERVAL
done

