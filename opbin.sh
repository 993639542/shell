#! /bin/bash
#Binlog日志用脚本开启，并脚本输出Binlog日志相关状态以及内容，然后使用相命令全部导出Binlog为SQL语句。
#

#sed -i "2ilog_bin=/data/binlog/mysql-bin" /root/test
#sed -i "3isync_binlog=1" /root/test
#sed -i "3ibinlog_format=row" /root/test

loca=$(mysql5.7 -e " select @@log_bin_basename" | awk 'NR==2')
log_bin=$(mysql5.7 -e "show master status" | awk 'NR==2{print $1}')
pos=$(mysql5.7 -e "show master status" | awk 'NR==2{print $2}')
dir=$(echo "${loca}" | xargs dirname)
if test ${loca} = "NULL"
then
	echo -e "\e[31m二进制日志开启失败\e[0m"
	exit 1
fi
echo "mysql log_bin 存放位置:${loca} " 
echo "mysql 当前二进制日志为:${log_bin}"
echo "mysql二进制日志节点为:${pos}"
/usr/local/mysql5.7/bin/mysqlbinlog --base64-output=decode-row -vvv ${dir}/${log_bin}  > ${dir}/bin.sql

