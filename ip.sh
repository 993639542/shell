#!/bin/bash
#随机生成网卡配置文件


for i in `seq 10`
do
	num=$[RANDOM%127+128]
	cat > /home/ens$i <<EOF
TYPE=Ethernet
PROXY_METHOD=none
ROWSER_ONLY=no
OOTPROTO=static
EFROUTE=yes
PV4_FAILURE_FATAL=no
PV6INIT=yes
PV6_AUTOCONF=yes
PV6_DEFROUTE=yes
PV6_FAILURE_FATAL=no
PV6_ADDR_GEN_MODE=stable-privacy
NAME=ens$i
EVICE=ens$i
NBOOT=yes
PADDR=192.168.75.$num
REFIX=24
ATEWAY=192.168.75.2
NS1=192.168.75.2
EOF
done

