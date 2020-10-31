#! /bin/bash
#脚本安装redis5.0集群
#

#获取本机ip
LocalIp=$(ifconfig ens33 | grep "broadcast" | awk '{print $2}')
#指定搭建服务数
num=6

website="http://download.redis.io/releases/redis-5.0.9.tar.gz?_ga=2.104516420.552921982.1602326718-1175443646.1602326718"
yum -y install wget
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum clean all
yum -y install gcc automake autoconf libtool make &>/dev/null
wget -O /opt/redis-5.0.9.tar.gz ${website}
tar -xf /opt/redis-5.0.9.tar.gz -C /usr/local
cd /usr/local/redis-5.0.9
make && make install
ln -s /usr/local/redis-5.0.9/src/redis-server /usr/local/bin

for i in $(seq 0 ${num})
do
	mkdir -p /data/redis/700${i}
        cat > /data/redis/700${i}/redis.conf <<EOF
        port 700${i}
        bind ${LocalIp}
        daemonize yes
        pidfile /var/run/redis_700${i}.pid
        cluster-enabled yes
        cluster-config-file nodes_700${i}.conf
        cluster-node-timeout 15000
        appendonly yes
EOF
done
redis-server /data/redis/7000/redis.conf
if $(netstat -nlpt | grep "7000" &>/dev/null )
then
	echo -e "\e[32mredis集群部署成功.\e[0m"
else
	echo -e "\e[31mredis集群部署失败.\e[0m"
fi
 

