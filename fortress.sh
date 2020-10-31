#! /bin/bash
#堡垒机
#by   20/9/5

trap   ""  INT QUIT  TSTP
clear
while :
do
	echo "******************"
	echo "*1.192.168.75.180*"
	echo "*2.192.168.75.181*"
	echo "*3.192.168.75.182*"
	echo "*4.退出          *"
	echo "******************"
	read -p "choose>" choose
	case $choose in
		'1')
			sshpass -p "123456" ssh -o StrictHostKeyChecking=no lxw@192.168.75.180
		;;
		'2')
			sshpass -p "123456" ssh -o StrictHostKeyChecking=no lxw@192.168.75.181
		;;
		'3')
			sshpass -p "123456" ssh -o StrictHostKeyChecking=no lxw@192.168.75.182
		;;
		'4')
			
			exit
		;;
		'*')
			continue
		;;
	esac
done

