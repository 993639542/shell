#! /bin/bash
#在同一台机器分别安装mysql5.6 5.7，5.6数据库端口3309，5.7端口3310，5.7中导入数据world.sql
#

echo "************"
echo "*1.mysql 5.6*"
echo "*2.mysql 5.7*"
echo "**.退出     *"
echo "************"

read -p "choose>" choose

case $choose in
	'1')
		yum -y install wget
		mkdir /usr/local/mysql5.6
		mkdir /data/5.6 -p
		useradd -r -M -s /sbin/nologin mysql &>/dev/null
		ls /etc/yum.repos.d/*.repo > /tmp/yum
		for file in $(cat /tmp/yum)
		do
			mv ${file} ${file}.bak
		done
		wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
		yum -y install cmake gcc-c++ opensssl openssl-devel ncurses-devel mlocate &>/dev/null
		yum -y install autoconf &>/dev/null
		updatedb
		loca=$(locate mysql-5.6.19.tar.gz | xargs dirname)
		cd ${loca}
		tar -xf mysql-5.6.19.tar.gz
		cd mysql-5.6.19
		cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql5.6 -DMYSQL_DATADIR=/data/5.6 -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_TCP_PORT=3306 -DMYSQL_UNIX_ADDR=/data/5.6/mysql.sock -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_INNODB_MEMCACHED=ON 
        if [ $? -ne 0  ]
		then
			echo -e "\e[31m5.6编译错误.\e[0m"
			exit 1
		fi		
		make && make install
		/usr/local/mysql5.6/scripts/mysql_install_db  --user=mysql --basedir=/usr/local/mysql5.6 --datadir=/data/5.6
		cat > /data/5.6/my.cnf <<EOF
[mysqld]
basedir=/usr/local/mysql5.6
datadir=/data/5.6/data
socket=/data/5.6/mysql.sock
log_error=/data/5.6/mysql.log
port=3306
server_id=6
EOF

		cat > /etc/systemd/system/mysqld3306.service <<EOF
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
ExecStart=/usr/local/mysql5.6/bin/mysqld  --defaults-file=/data/5.6/my.cnf
LimitNOFILE = 5000
EOF
		chown mysql:mysql /usr/local/mysql5.6 -R
		chown mysql:mysql /data -R
		systemctl daemon-reload
		systemctl start mysqld3306
		ln -s /usr/local/mysql5.6/bin/mysql /usr/local/sbin/mysql5.6
	;;
	'2')
		yum -y install wget
		mkdir /usr/local/mysql5.7
		mkdir /data/5.7 -p
		mkdir /tmp/5.7 -p
		mkdir /var/log/mysql
		useradd -r -M -s /sbin/nologin mysql &>/dev/null
		ls /etc/yum.repos.d/*.repo > /tmp/yum
		for file in $(cat /tmp/yum)
		do
			mv ${file} ${file}.bak
		done
		wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo &>/dev/null
		yum -y install cmake gcc-c++ opensssl openssl-devel ncurses-devel mlocate &>/dev/null
		updatedb
		loca=$(locate mysql-boost-5.7.30.tar_2.gz | xargs dirname)
		cd ${loca}
		tar -xf mysql-boost-5.7.30.tar_2.gz
		cd mysql-5.7.30
		cp -r boost/ /usr/local 
		cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql5.7 -DMYSQL_DATADIR=/data/5.7 -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_TCP_PORT=3307 -DMYSQL_UNIX_ADDR=/data/5.7/mysql.sock -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/usr/local/boost -DWITH_INNODB_MEMCACHED=ON 
        if [ $? -ne 0  ]
		then
			echo -e "\e[31m5.7编译错误.\e[0m"
			exit 2
		fi		
		make && make install
		/usr/local/mysql5.7/bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql5.7 --datadir=/data/5.7
		cat > /data/5.7/my.cnf <<EOF
[mysqld]
basedir=/usr/local/mysql5.7
datadir=/data/5.7
socket=/data/5.7/mysql.sock
log_error=/var/log/mysql/mysql5.7.log
port=3307
server_id=7
EOF

		cat > /etc/systemd/system/mysqld3307.service <<EOF
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
ExecStart=/usr/local/mysql5.7/bin/mysqld  --defaults-file=/data/5.7/my.cnf
LimitNOFILE = 5000
EOF
		chown mysql:mysql /usr/local/mysql5.7 -R
		chown mysql:mysql /data -R
		systemctl daemon-reload
		systemctl start mysqld3307
		ln -s /usr/local/mysql5.7/bin/mysql /usr/local/sbin/mysql5.7
	;;
	'*')
		echo "input error."
		break
	;;
esac
