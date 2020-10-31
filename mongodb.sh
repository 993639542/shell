#! /bin/bash
#mongodb免编译安装脚本。
#

website="https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.6.20.tgz"
#创建所需用户和组
useradd -s /sbin/nologin -M -r mongod
#创建mongodb所需目录结构
mkdir -p /mongodb/conf
mkdir -p /mongodb/log
mkdir -p /mongodb/data

yum -y install wget 
wget -O /opt/mongodb-linux-x86_64-rhel70-3.6.20.tgz ${website}
tar -xf /opt/mongodb-linux-x86_64-rhel70-3.6.20.tgz -C /opt 
cp -r /opt/mongodb-linux-x86_64-rhel70-3.6.20/bin /mongodb
chown mongodod:mongod /mogodb -R
/mongodb/bin/mongod --dbpath=/mongodb/data --logpath=/mongodb/log/mongodb.log --port=27017 --logappend --fork
if $(netstat -nlpt | grep "27017" &>/dev/null)
then
	echo -e "\e[32mmongodb安装成功\e[0m"
else
	echo -e "\e[31mmongodb安装失败\e[0m"
fi
