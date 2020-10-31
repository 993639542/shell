#!/bin/bash
#Determine which hosts are on in the current network segment
#by white_pig 20.8.9
count=0
ip=$(ifconfig | grep "inet" | awk 'NR==1' | awk '{print $2}' | cut -d. -f1,2,3)
for num in `seq 1 255`
do
	ping -c 2 -i 0.3 -W 1 $ip.$num &>/dev/null
	if [ $? -eq 0 ]
	then
		echo -e "\e[1;32m $ip.$num is on. \e[0m"
		let count+=1
	fi	
done
echo -e "\e[1;32m There are $count hosts on in the $ip. segment. \e[0m"
