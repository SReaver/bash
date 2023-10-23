#!/usr/bin/env bash
declare -i num=80
if [ $# -eq 1 ]; then
	num=$1
fi
SPACE=$(df -kh . | tail -n1 | awk '{print $5}')
current=${SPACE::2}

[[ ${current} -gt ${num} ]] && echo "WARNING!!! Free space is less then ${num}%"