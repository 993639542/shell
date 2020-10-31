#! /bin/bash
#nginx安装
#

#yum -y install wget 
#wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
#wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
websize="http://nginx.org/download/nginx-1.18.0.tar.gz"
#创建nginx运行用户
useradd -u 6666 -M -s /sbin/nologin  nginx &>/dev/null
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

