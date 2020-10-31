#! /bin/bash
#免密设置
#

db2="192.168.75.142"
db3="192.168.75.143"

pass='123456'

yum -y install expect sshpass
/usr/bin/expect <<EOF
spawn ssh-keygen
expect ":" {send "\r"}
expect ":" {send "\r"}
expect ":" {send "\r"}
expect eof
EOF

mv /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
sshpass -p "${pass}" ssh -o StrictHostKeyChecking=no ${db2} "echo"
sshpass -p "${pass}" ssh -o StrictHostKeyChecking=no ${db3} "echo"
sshpass -p "${pass}"  scp -r /root/.ssh/  ${db2}:/root
sshpass -p "${pass}"  scp -r /root/.ssh/  ${db3}:/root 


