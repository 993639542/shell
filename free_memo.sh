#!/bin/bash
#check root free_memo
#by white_pig 2020.8.9
used=$(df -h | grep "root" | awk '{print $5}' | cut -d% -f1)
free=$(expr 100 - $used)
if [ $free -le 20 ]
then
	echo -e "\e[1;31m Your memory is almost full. \e[0m"
else
	echo -e "\e[1;32m You have $free percent of your current memory. \e[0m"
fi

