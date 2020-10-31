#!/bin/bash
#模拟数据库故障后，自动拉起数据库并加入mha
#by white_pig 2020.8.11

user="mha"
pass="123"
num=$[RANDOM%20+10]
mha_ser=192.168.75.182

local_ip=`ifconfig | tr '\n' ' ' | grep "ens33:" | sed 's/ * / /g' | cut -d' ' -f6`
ssh $mha_ser "sed -i '21a [server$num]\nhostname=$local_ip\nport=3306' /etc/mha/app1.cnf"
ssh $mha_ser "masterha_check_ssh --conf=/etc/mha/app1.cnf &> /root/ip.txt"
scp $mha_ser:/root/ip.txt /home/ip1.txt
cat /home/ip1.txt | grep "Connecting via SSH from" | awk '{print $12}' | cut -d'@' -f2 | cut -d'(' -f1 | uniq >/home/ip.txt 

master=`ssh $mha_ser "cat /var/log/mha/app1/manager | grep "Master" | tail -1 | awk '{print $4}' | cut -d'(' -f1" | awk '{print $4}' `

for ip in `cat /home/ip.txt`
do
	if test $ip != $master && test $ip != $local_ip
	then
		slave=$ip
	fi
done


systemctl start mysqld
mysqldump -u${user} -p${pass} -h$master destoon > /tmp/mysql.sql
mysql -uroot -p${pass} destoon < /tmp/mysql.sql
bin_log=$(mysql -${user} -p${pass} -h$slave -e "show slave status\G" | grep "Master_Log_File:" | head -1 | cut -d: -f2 | sed 's/ //g')
bin_pos=$(mysql -${user} -p${pass} -h$slave -e "show slave status\G" | grep "Read_Master_Log_Pos:" | head -1 | cut -d: -f2 | sed 's/ //g')
mysql -uroot -p${pass} -e "stop slave;"
mysql -uroot -p${pass} -e "change master to master_host='$master',master_user='mysql',master_password='${pass}',master_log_file='$bin_log',master_log_pos=$bin_pos;"
mysql -uroot -p${pass} -e "start slave;"
IQ_status=$(mysql -uroot   -e "show slave status\G" | grep 'Slave_IO_Running:' | cut -d: -f2 | sed 's/ //g')
SQL_status=$(mysql -uroot  -e "show slave status\G" | grep 'Slave_SQL_Running:' | cut -d: -f2 | sed 's/ //g')
if test $IQ_status = 'Yes' && test $SQL_status = 'Yes'
then
	echo "success!"
else
	echo "It's something wrong in slave."
	exit 1
fi

ssh $mha_ser "masterha_check_repl  --conf=/etc/mha/app1.cnf"
ssh $mha_ser "nohup masterha_manager --conf=/etc/mha/app1.cnf --remove_dead_master_conf --ignore_last_failover  < /dev/null> /var/log/mha/app1/manager.log 2>&1 &"
sleep 5
ssh $mha_ser "masterha_check_status --conf=/etc/mha/app1.cnf > /tmp/test.txt"
scp root@$mha:/tmp/test.txt /tmp/test.txt
grep "master:" /tmp/test.txt

if [ $? -eq 0 ]
then
	echo "MHA success."
fi
