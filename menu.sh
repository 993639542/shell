#! /bin/bash
#配置yum本地源，部署dns服务，部署dhcpd,配置ftp服务（不支持匿名用户，支持虚拟用户）
#by lxw 2020/09/06

while :
do
	clear
	echo "#################"
	echo "#1.配置本地yum源#"
	echo "#2.部署dns服务  #"
	echo "#3.部署dhcpd    #"
	echo "#4.配置ftp服务  #"
	echo "#5.退出         #"
	echo "###############"
	read -p "choose>" choose
	case ${choose} in
		'1')
			source /root/module/localyum.sh
			localyum
		;;
		'2')
			source /root/module/dns.sh
			dns
		;;		
		'3')
			source /root/module/dhcpd.sh
			dhcpd
		;;
		'4')
			source /root/module/ftp.sh
			ftp
		;;
		'5')
			break
		;;
		'*')
			continue
		;;
	esac
done
