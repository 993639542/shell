#! /bin/bash
#LNMP脚本一键安装编写
#

function nginx()
{
	yum -y install wget 
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
	wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
	websize="http://nginx.org/download/nginx-1.18.0.tar.gz"
	#创建nginx运行用户
	useradd -M -s /sbin/nologin -r nginx &>/dev/null
	#安装Nginx相关依赖
	yum -y install gcc  zlib zlib-devel  pcre pcre-devel openssl openssl-devel &>/dev/null
	wget -O /opt/nginx-1.18.0.tar.gz ${websize}
	tar -xf /opt/nginx-1.18.0.tar.gz -C /opt
	cd /opt/nginx-1.18.0
	/opt/nginx-1.18.0/configure --user=nginx --group=nginx --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_sub_module --with-http_ssl_module --with-pcre
	
	#检查nginx是否编译成功
	if [ $? -ne 0 ]
	then
		echo "nginx编译失败"
		exit 1
	fi
	
	#检查nginx是否安装成功
	make && make install
	if [ $? -ne 0 ]
	then
		echo "nginx安装失败"
		exit 2
	else
		echo "nginx安装成功"
	fi
}

function mysql()
{
	mariadb=$(rpm -qa mariadb)
	rpm -e ${mariadb} --nodeps
	yum -y install wget &>/dev/null
	wget -O /opt/mysql-boost-5.7.30.tar.gz https://downloads.mysql.com/archives/get/p/23/file/mysql-boost-5.7.30.tar.gz
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
	tar -xf /opt/mysql-boost-5.7.30.tar.gz -C /opt
	cd /opt/mysql-5.7.30
	cp -r /opt/mysql-5.7.30/boost /usr/local
	#安装mysql相关依赖
	yum -y install cmake gcc-c++ opensssl openssl-devel ncurses-devel
	#创建mysql通用配置
	useradd -r -M -s /sbin/nologin mysql 
	mkdir /usr/local/mysql
	mkdir /data/mysql -p	
	#编译
	cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/data/mysql  -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_TCP_PORT=3306 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/usr/local/boost -DWITH_INNODB_MEMCACHED=ON
	if [ $? -ne 0 ]
	then
		echo "mysql编译失败"
		exit 1
	fi
	#安装
	make && make install
	#初始化
	/usr/local/mysql/bin/mysqld --initialize-insecure  --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysqldata
	#配置文件
	cat > /etc/my.cnf <<EOF
[mysqld]
user=mysql                                        #指定用户
basedir=/usr/local/mysql                #应用程序所在目录
datadir=/data/mysql                    #数据库数据存储目录路径
server_id=6                                      #id号
log-error=/data/mysql                   #错误日志存放路径。
pid-file=/data/mysql/mysql.pid       #进程pid文件。
port=3306                                       #默认端口号
socket=/tmp/mysql.sock     #sock连接的接口
EOF
}

function php()
{
	yum -y install wget &>/dev/null
	wget -O /opt/php-7.0.33.tar.gz https://www.php.net/distributions/php-7.0.33.tar.gz
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    	wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
	tar -xf /opt/php-7.0.33.tar.gz -C /opt
	cd /opt/php-7.0.33
	#安装依赖
	yum install autoconf  gcc  libxml2-devel openssl-devel curl-devel libjpeg-devel libpng-devel libXpm-devel freetype-devel libmcrypt-devel make ImageMagick-devel  libssh2-devel gcc-c++ cyrus-sasl-devel -y
	./configure  --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/etc/php.d  --disable-ipv6  --enable-bcmath  --enable-calendar  --enable-exif  --enable-fpm   --enable-ftp  --enable-gd-jis-conv   --enable-gd-native-ttf  --enable-inline-optimization  --enable-mbregex  --enable-mbstring   --enable-mysqlnd  --enable-opcache   --enable-pcntl   --enable-shmop   --enable-soap   --enable-sockets   --enable-static  --enable-sysvsem   --enable-wddx   --enable-xml   --with-curl  --with-gd   --with-jpeg-dir   --with-freetype-dir    --with-xpm-dir   --with-png-dir   --with-gettext   --with-iconv  --with-libxml-dir   --with-mcrypt   --with-mhash   --with-mysqli   --with-pdo-mysql   --with-pear   --with-openssl   --with-xmlrpc   --with-zlib  --disable-debug   --disable-phpdbg 
	make && make install
	cp /usr/local/php/etc/php-fpm.d/www.conf.default ../php-fpm.conf
}

clear
echo "**********************************************"
echo "LNMP一键安装"
echo "**********************************************"
while :
do
	echo "****************"
	echo "*1.install nginx*"
	echo "*2.install mysql*"
	echo "*3.install php  *"
	echo "*4.install all  *"
	echo "*5.退出         *"
	echo "****************"
	read -p "choose>" choose
	case $choose in
		'1')
			nginx
		;;
		'2')
			mysql
		;;
		'3')
			php
		;;
		'4')
			nginx
			mysql
			php
		;;
		'5')
			clear
			echo "================================================"
			echo -e "\e[32mThanks for using my bash script.\e[0m"
			break
		;;
	esac
done




















