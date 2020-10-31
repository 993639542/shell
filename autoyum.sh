#!/bin/bash
#自动部署yum源
#by white_pig 8/7

if test -z $1
then
	echo -e "\e[41;37m input error! you should input like ./$0 /DIR \e[0m"
	exit 1
fi
updatedb
loc=$(locate $1)
if test -d $loc
then
	echo -e "\e[1;32m input a right dir \e[0m"
else
	echo -e "\e[41;37m input not exist or incomplete! \e[0m"
	exit 2
fi

ifmount=$(df | grep sr0 | cut -f1 | awk '{print $1}' | cut -d/ -f3)
mountplace=$(df | grep sr0 | awk '{print $6}')
if test ! -z "$ifmount" 
then
	if test $1 != $mountplace
	then
		umount $mountplace
	else
		echo -e "\e[1;32m The iso is mounted. \e[0m"
	fi
else
	mount /dev/sr0 $1
	echo -e "\e[1;32m auto mounted. \e[0m"
fi
dir=$(find $1 -name "repodata" | xargs dirname)
echo "[local]" > /etc/yum.repos.d/local.repo
echo "name='local yum'" >> /etc/yum.repos.d/local.repo
echo "baseurl=file://$dir" >> /etc/yum.repos.d/local.repo
echo "enabled=1"  >> /etc/yum.repos.d/local.repo
echo "gpgcheck=0"  >> /etc/yum.repos.d/local.repo
echo -e "\e[1;32m local yum auto install success! \e[0m"

