#! /bin/bash
#一键搭建LAMP服务
#

#======================================================================================================
function http()
{
echo -e "\e[32m=======================start install httpd======================================\e[0m"
sleep 5
yum -y install httpd &>/dev/null
systemctl start httpd
systemctl enable httpd
if ! $(httpd -M | grep "php")
then
	yum -y install php &>/dev/null
fi
if ! $(php-m | grep "mysql")
then
	yum -y install php-mysql
fi

}

#======================================================================================================
function mysql()
{
echo -e "\e[32m=======================start install mysql5.7======================================\e[0m"
sleep 5
useradd -r -M -s /sbin/nologin mysql &>/dev/null
mkdir /usr/local/mysql5.7
mkdir /data/5.7 -p
mkdir /var/log/mysql5.7
mkdir /home/mysql5.7
yum -y install cmake gcc-c++ opensssl openssl-devel ncurses-devel mlocate &>/dev/null
updatedb
loca=$(locate mysql-boost-5.7.30.tar_2.gz | xargs dirname)
if test -z ${loca}
then
	echo -e "\e[31m请上传mysql5.7源码包\e[0m"
	exit 1
fi
cd ${loca}
tar -xf mysql-boost-5.7.30.tar_2.gz
cd mysql-5.7.30
cp -r boost/ /usr/local 
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql5.7 \
	  -DMYSQL_DATADIR=/data/5.7 \
	  -DDEFAULT_CHARSET=utf8 \
	  -DDEFAULT_COLLATION=utf8_general_ci \
	  -DMYSQL_TCP_PORT=3306 \
	  -DMYSQL_UNIX_ADDR=/home/mysql5.7/mysql.sock \
	  -DWITH_MYISAM_STORAGE_ENGINE=1 \
	  -DWITH_INNOBASE_STORAGE_ENGINE=1 \
	  -DDOWNLOAD_BOOST=1 \
	  -DWITH_BOOST=/usr/local/boost \
	  -DWITH_INNODB_MEMCACHED=ON 
if [ $? -ne 0  ]
then
	echo -e "\e[31m5.7编译错误.\e[0m"
	exit 2
fi		
make && make install
if [ $? -ne 0 ]
then
	echo -e "\e[31mmysql5.7 install failed\e[0m"
	exit 3
fi
/usr/local/mysql5.7/bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql5.7 --datadir=/data/5.7
if [ $? -ne 0 ]
then
	echo -e "\e[31mmysql初始化失败.\e[0m"
	exit 4
fi
cat > /data/5.7/my.cnf <<EOF
[mysqld]
basedir=/usr/local/mysql5.7
datadir=/data/5.7
socket=/home/mysql5.7/mysql.sock
log_error=/var/log/mysql5.7/mysql.log
port=3306
server_id=7
EOF
cat > /etc/systemd/system/mysqld3306.service <<EOF
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refmann/using-systemd.html
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
chown mysql:mysql /home/mysql5.7
chown mysql:mysql /var/log/mysql5.7
systemctl daemon-reload
systemctl start mysqld3306
port=$(netstat -nlpt | grep "tcp" | grep "mysqld" | awk -F: '{print $4}')
if test -z ${port}
then
	echo -e "\e[31mmysql启动失败，请检查\e[0m"
	exit 5
fi
echo "export PATH=/usr/local/mysql/bin:$PATH" >> /etc/profile
source /etc/profile
}

#======================================================================================================
function php()
{
echo -e "\e[32m=======================start install php======================================\e[0m"
sleep 5
yum -y install libxml2-devel.x86_64 openssl-devel.x86_64 bzip2-devel.x86_64 libpng-devel.x86_64 freetype-devel.x86_64 libjpeg-turbo-devel.x86_64 mlocate httpd-devel &> /dev/null 
updatadb
locaphp=$(locate libmcrypt-2.5.8 | xargs dirname)
if test -z ${locaphp}
then
	echo -e "\e[31m请上传php相关包\e[0m"
	exit 6
fi
cd $locaphp
tar -xf libmcrypt-2.5.8.tar.gz
 cd libmcrypt-2.5.8
./configure
make && make install
export  LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
echo 'LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> /etc/profile
cd ..
tar  -xf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9/
./configure
make && make install
cd ..
tar -xf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8/
./configure
make && make install
cd ..
tar -xjf php-5.6.39.tar.bz2
cd php-5.6.39/
 ./configure --prefix=/usr/local/php5.6 --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --with-apxs2=/usr/bin/apxs --with-mysqli=mysqlnd --with-openssl --enable-fpm --enable-sockets --enable-sysvshm --enable-mbstring --with-freetype-dir --with-gd --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --with-mhash --with-mcrypt --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-bz2 --enable-maintainer-zts --without-pear  --disable-phar
make
make test
make install
mv php-fpm.conf.default php-fpm.conf

}
#======================================================================================================

function discuz()
{
cat > /etc/httpd/conf.d/discuz.conf <<EOF
<VirtualHost *:80>
    DocumentRoot    /var/www/discuz
    ServerName  www.mydiscuz.com
    CustomLog   logs/discuz_access.log  combinedio
    <Directory "/var/www/discuz">
        Require all granted
    </Directory>
</VirtualHost>
EOF
updatedb
loca=$(locate Discuz_X3.4_GIT_SC_UTF8.zip | xargs dirname) 
if test -z ${loca}
then
    echo -e "\e[31m请上传论坛源码。。。\e[0m"
    exit 7   
fi
yum -y install unzip &>/dev/null
cd ${loca}
unzip ${loca}/Discuz_X3.4_GIT_SC_UTF8.zip
mkdir /var/www/discuz -p
mv ${loca}/dir_SC_UTF8/upload/* /var/www/discuz/
chown apache:apache /var/www/discuz -R

}

yum -y install wget &> /dev/null
ls /etc/yum.repos.d/*.repo > /tmp/yum
for file in $(cat /tmp/yum)
do
	mv ${file} ${file}.bak
done
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo &>/dev/null
yum clean all

while :
do
	echo "****************"
	echo "*1.install httpd*"
	echo "*2.install mysql*"
	echo "*3.install php  *"
	echo "*4.install all  *"
	echo "*5.论坛搭建     *"
	echo "*6.退出         *"
	echo "****************"
	read -p "choose>" choose
	case $choose in
		'1')
			http
		;;
		'2')
			mysql
		;;
		'3')
			php
		;;
		'4')
			http
			mysql
		;;
		'5')
			discuz	
		;;
		'6')
			clear
			echo "================================================"
			echo -e "\e[32mThanks for using my bash script.\e[0m"
			break
		;;
	esac
done


