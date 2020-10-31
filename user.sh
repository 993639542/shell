#!/bin/bash
#create user
#by white_pig 2020.8.9

case $1 in
	$# -eq 1)
	useradd $1
	echo "123456" | passwd --stdin $1
	chage -d0
	;;
	$# -eq 2)
	useradd $1
	echo "$2" | passwd --stdin $1
	;;
	$# -gt 2)
	:wq

