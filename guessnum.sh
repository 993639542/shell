#!/bin/bash
#guess a rand num
#by white_pig 2020.8.9
num=$[RANDOM%10+1]
count=0
echo $num
while [ $count -lt 3 ]
do
	read -p "Please input your guessnum:" guess
	let count+=1
	if [ $num -eq  $guess ]
	then
		echo -e "\e[1;32m Wow,you get it the $count time. \e[0m"
		exit 
	fi

done
if [ $count -eq 3 ]
then
	echo "错误次数太多退出脚本"
fi
