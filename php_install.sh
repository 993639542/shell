#! /bin/bash
#php7.027安装
#

#yum -y install wget 
#wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
#wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /opt/php-7.0.27.tar.gz https://www.php.net/distributions/php-7.0.27.tar.gz
#安装依赖
yum install autoconf  gcc  libxml2-devel openssl-devel curl-devel libjpeg-devel libpng-devel libXpm-devel freetype-devel libmcrypt-devel make ImageMagick-devel  libssh2-devel gcc-c++ cyrus-sasl-devel -y
tar -xf /opt/php-7.0.27.tar.gz -C /opt
cd /opt/php-7.0.27
./configure  \
        --prefix=/usr/local/php \
        --with-config-file-path=/usr/local/php/etc \
        --with-config-file-scan-dir=/usr/local/php/etc/php.d \
        --disable-ipv6 \
        --enable-bcmath \
        --enable-calendar \
        --enable-exif \
        --enable-fpm \
        --with-fpm-user=nobody \
        --with-fpm-group=nobody \
        --enable-ftp \
        --enable-gd-jis-conv \
        --enable-gd-native-ttf \
        --enable-inline-optimization \
        --enable-mbregex \
        --enable-mbstring \
        --enable-mysqlnd \
        --enable-opcache \
        --enable-pcntl \
        --enable-shmop \
        --enable-soap \
        --enable-sockets \
        --enable-static \
        --enable-sysvsem \
        --enable-wddx \
        --enable-xml \
        --with-curl \
        --with-gd \
        --with-jpeg-dir \
        --with-freetype-dir \
        --with-xpm-dir \
        --with-png-dir \
        --with-gettext \
        --with-iconv \
        --with-libxml-dir \
        --with-mcrypt \
        --with-mhash \
        --with-mysqli \
        --with-pdo-mysql \
        --with-pear \
        --with-openssl \
        --with-xmlrpc \
        --with-zlib \
        --disable-debug \
        --disable-phpdbg 
if [ $? -ne 0 ]
then
	echo "php编译失败"
	exit 1
fi
make && make install
cp php.ini-development /usr/local/php/etc/php.ini
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.conf