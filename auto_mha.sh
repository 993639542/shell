#!/bin/bash
#模拟数据库故障后，自动拉起数据库并加入mha
#by white_pig 2020.8.11

user="mha"
pass="123"
num=$[RANDOM%20+10]
mha_ser=192.168.75.133

local_ip=`ifconfig | tr '\n' ' ' | grep "ens33:" | sed 's/ * / /g' | cut -d' ' -f6`
ssh $mha_ser "echo -e '[server${num}]\nhostname=${local_ip}\nport=3306' >> /etc/mha/app1.cnf"
ssh $mha_ser "masterha_check_ssh --conf=/etc/mha/app1.cnf &> /root/ip.txt"
scp $mha_ser:/root/ip.txt /home/ip1.txt
cat /home/ip1.txt | grep "Connecting via SSH from" | awk '{print $12}' | cut -d'@' -f2 | cut -d'(' -f1 | uniq >/home/ip.txt 
for ip in $(cat /home/ip.txt)
do
	if test ${local_ip} != ${ip}
	then
		retu=$(mysql -u${mha} -p${pass} -h${ip} -e "show slave status\G")
		if test -z ${retu}
		then
			master=${ip}
		fi
	fi
done
systemctl start mysqld
mysql -e "stop slave"
mysql -e "reset slave all"
mysql -e "CHANGE MASTER TO MASTER_HOST='$master',MASTER_USER='repl',MASTER_PASSWORD='123',MASTER_AUTO_POSITION=1"
mysql -e "start slave"
ssh $mha_ser "masterha_check_ssh --conf=/etc/mha/app1.cnf"
if [ $? -ne 0 ]
then
	echo "互信失败"
	exit 1
fi
ssh $mha_ser "masterha_check_repl  --conf=/etc/mha/app1.cnf"
if [ $? -ne 0 ]
then
	echo "主从失败"
	exit 2
fi
ssh $mha_Ser " nohup masterha_manager --conf=/etc/mha/app1.cnf --remove_dead_master_conf --ignore_last_failover  < /dev/null> /var/log/mha/app1/manager.log 2>&1 &"

echo "success"
