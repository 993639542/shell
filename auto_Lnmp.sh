#!/bin/bash
#Auto install LNMP


updatedb
echo "-----------------------------------------------"
echo "1)nginx install"
echo "2)php install"
echo "3)mysql install"
read -t 30 -p "Please input your choise:" choise
if [ $choise -eq 1 ]
	then
		lote=$(locate nginx-1.14.2-1.el7_4.ngx.x86_64.rpm | xargs dirname)
		if [ `echo $?` -eq 0 ] 
		then
			cd $lote
			echo "start install nginx"
			rpm -i nginx-1.14.2-1.el7_4.ngx.x86_64.rpm
		else
			echo "Your computer does not have nginx installation package"
		fi
elif [ $choise -eq 2 ]
	then
		echo -e "\033[42;5m start install php \033[0m"
		yum -y install libxml2-devel.x86_64  
		yum -y install openssl-devel.x86_64 
		yum -y install bzip2-devel.x86_64  
		yum -y install libpng-devel.x86_64  
		yum -y install freetype-devel.x86_64
		yum -y install libjpeg-devel.x86_64 
		locaphp=$(locate libmcrypt-2.5.8 | xargs dirname)
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
		tar -xf php-5.6.39.tar.bz2
		cd php-5.6.39/
		 ./configure --prefix=/usr/local/php5.6 --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --with-mysqli=mysqlnd --with-openssl --enable-fpm --enable-sockets --enable-sysvshm --enable-mbstring --with-freetype-dir --with-gd --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --with-mhash --with-mcrypt --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-bz2 --enable-maintainer-zts --without-pear  --disable-phar
		make
		make test
		make install
		echo -e "\033[42m OK! \033[0m"
elif [ $choise -eq 3 ]
	then
		echo "start install mysql"
		locamysql=$(locate mysql-5.7.24-1.el7.x86_64.rpm-bundle.tar | xargs dirname)
		cd $locamysql
		tar -xf mysql-5.7.24-1.el7.x86_64.rpm-bundle.tar
		rpm -e --nodeps mariadb-libs
		rpm -ivh mysql-community-common-5.7.24-1.el7.x86_64.rpm
		rpm -ivh mysql-community-libs-5.7.24-1.el7.x86_64.rpm
		rpm -ivh mysql-community-client-5.7.24-1.el7.x86_64.rpm
		rpm -ivh mysql-community-devel-5.7.24-1.el7.x86_64.rpm
		rpm -ivh mysql-community-server-5.7.24-1.el7.x86_64.rpm
		service mysqld start
		cat /var/log/mysqld.log | grep root
else
		echo "Input error!Please try agian!"
		exit 100	
fi


