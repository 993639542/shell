#!/bin/bash
#identify whether the current user is root
#by white_pig 2020.8.9
user=`whoami`
uid=$(cat /etc/passwd | grep "$user:x" | cut -d: -f3)
if [ $uid -eq 0 ]
then
	echo -e "\e[1;32m You are root. \e[0m"
else
	echo -e "\e[1;31m You are not root.You are $user. \e[0m"
fi
