#! /bin/bash
#MongoDB复制集RS,一主一从一投票
#

#mongod 安装
function mongod()
{	website="https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.6.20.tgz"
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
}

#mongod()

#服务器IP
local_ip=$(ifconfig ens33 | grep "broadcast" | awk '{print $2}')
#三台mongodb监听的端口
port1=28017
port2=28018
port3=28019
创建三台mongodb的相关目录
mkdir -p /mongodb/${port1}/conf /mongodb/$port1/data /mongodb/$port1/log
mkdir -p /mongodb/${port2}/conf /mongodb/$port2/data /mongodb/$port2/log
mkdir -p /mongodb/${port3}/conf /mongodb/$port3/data /mongodb/$port3/log

#配置文件
cat > /mongodb/$port1/conf/mongod.conf <<EOF
systemLog:
  destination: file
  path: /mongodb/$port1/log/mongodb.log
  logAppend: true
storage:
  journal:
    enabled: true
  dbPath: /mongodb/$port1/data
  directoryPerDB: true
  #engine: wiredTiger
  wiredTiger:
    engineConfig:
      cacheSizeGB: 1
      directoryForIndexes: true
    collectionConfig:
      blockCompressor: zlib
    indexConfig:
      prefixCompression: true
processManagement:
  fork: true
net:
  bindIp: ${local_ip},127.0.0.1
  port: $port1
replication:
  oplogSizeMB: 2048
  replSetName: my_repl
EOF

cp  /mongodb/$port1/conf/mongod.conf  /mongodb/$port2/conf/
cp  /mongodb/$port1/conf/mongod.conf  /mongodb/$port3/conf/
sed -i "s/$port1/$port2/g" /mongodb/$port2/conf/mongod.conf
sed -i "s/$port1/$port3/g" /mongodb/$port3/conf/mongod.conf
chown -R mongod:mongod /mongodb

/mongodb/bin/mongod -f /mongodb/$port1/conf/mongod.conf
/mongodb/bin/mongod -f /mongodb/$port2/conf/mongod.conf
/mongodb/bin/mongod -f /mongodb/$port3/conf/mongod.conf

/mongodb/bin/mongo --port $port1 admin <<EOF
config = {_id: 'my_repl', members: [
                          {_id: 0, host: "${local_ip}:${port1}"},
                          {_id: 1, host: '${local_ip}:${port2}'},
                          {_id: 2, host: '${local_ip}:${port3}',"arbiterOnly":true}]
          } 
rs.initiate(config) 
EOF
