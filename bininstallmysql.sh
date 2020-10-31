#! /bin/bash
#
#

yum -y install libaio-devel
#tar -xf /root/mysql-5.7.30-linux-glibc2.12-x86_64.tar.gz -C /usr/local
#mv /usr/local/mysql-5.7.30-linux-glibc2.12-x86_64 /usr/local/mysql
rpm -e mariadb-libs --nodeps
mkdir /data/mysql -p
mkdir /var/log/mysql 
mkdir /var/log/binlog
useradd -M -s/sbin/nologin -r mysql
/usr/local/mysql/bin/mysqld --initialize-insecure  --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql
cat > /etc/my.cnf << EOF
[mysqld]
user=mysql
basedir=/usr/local/mysql
datadir=/data/mysql
server_id=1
log-error=/var/log/mysql/error.log
pid-file=/tmp/mysql.pid
port=3306
socket=/tmp/mysql.sock
log_bin=/var/log/binlog/bin
sync_binlog=1
binlog_format=row
gtid-mode=on
enforce-gtid-consistency=true
secure-file-priv=/tmp
log-slave-updates=1
autocommit=0
slow_query_log=1
slow_query_log_file=/var/log/mysql/slow.log
long_query_time=1
log_queries_not_using_indexes=1
[mysql]
socket=/tmp/mysql.sock
prompt=[\\d]>
[client]
socket=/tmp/mysql.sock
EOF

cat > /etc/systemd/system/mysqld.service <<EOF
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target
[Install]
WantedBy=multi-user.target
[Service]
User=mysql
Group=mysql
ExecStart=/usr/local/mysql/bin/mysqld  --defaults-file=/etc/my.cnf
LimitNOFILE = 5000
EOF

chown mysql:mysql /data/mysql -R
chown mysql:mysql /var/log/mysql -R
chown mysql:mysql /var/log/binlog -R

echo "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
source /etc/profile

systemctl daemon-reload
systemctl start mysqld

