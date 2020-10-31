#!/bin/bash
#monitor server
#by white_pig 2020
M_IPADDR=$(ifconfig ens33 | grep broad | awk {print'$2'})
DATE=$(date)
if [ -f $1 -a "$1" == "server.txt" ]
	then
	for i in `cat server.txt`
	do	
	value=$(ps aux | grep $i | grep -v grep | grep -v $0 | wc -l)
	if [ $value -eq 0 ]
		then
		echo -e "\033[41m The $i server connecting refused.\033[0m"
cat > eamil.txt << EOF
****************server monitor*****************
通知类型：故障
服务器：$i
主机：$M_IPADDR
状态：警告
日期/时间：$DATE		
额外信息：
CRITICAL - $i Server Connection Refused,Please Check.
*****************************************************
EOF
		echo -e "\033[41m The Monitor $i warning,Please Check!\033[0m"
		mail -s "M_IPADDR $i Warning" white_pig1@163.com < eamil.txt >>/dev/null 2>&1
	else
		echo -e "\033[42m OK! \033[0m"

	fi
	done		
else	
	value=$(ps aux | grep $1 | grep -v grep | grep -v $0 | wc -l)
	if [ $value -eq 0 ]
		then
		echo -e "\033[41m The $1 server connecting refused.\033[0m"
		
cat > eamil.txt << EOF
****************server monitor*****************
通知类型：故障
服务器：$1
主机：$M_IPADDR
状态：警告
日期/时间：$DATE		
额外信息：
CRITICAL - $1 Server Connection Refused,Please Check.
*****************************************************
EOF
		echo -e "\033[41m The Monitor $1 warning,Please Check!\033[0m"
		mail -s "M_IPADDR $1 Warning" white_pig1@163.com < eamil.txt >>/dev/null 2>&1
	else
		echo -e "\033[42m OK! \033[0m"
	fi
fi
