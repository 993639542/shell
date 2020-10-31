#! /bin/bash
#LAMP禅道源码安装
#

yum -y install http php php-mysql wget zip unzip &>/dev/null
wget -O /opt/ZenTaoPMS.12.3.3.zip https://www.zentao.net/dl/ZenTaoPMS.12.3.3.zip
unzip /opt/ZenTaoPMS.12.3.3.zip -d /opt
cat > /etc/httpd/conf.d/chandao.conf <<EOF
<VirtualHost *:80>
        DocumentRoot /opt/zentaopms/www
        ServerName      www.myweb.com
        CustomLog   logs/chandao_access.log  combinedio
        <Directory "/opt/zentaopms/www">
                Require all granted
        </Directory>
</VirtualHost>
EOF

chown apache:apache /opt/zentaopms/ -R
systemctl start httpd

