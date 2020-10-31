#! /bin/bash
#分片集群安装,单机器，一个路由请求router，三台config_server，两个shard节点分别为一主一从一ab
#

local_ip=$(ifconfig ens33 | grep "broadcast" | awk '{print $2}')
#服务端口
port1=38017
port2=38018
port3=38019
port4=38020
port5=38021
port6=38022
port7=38023
port8=38024
port9=38025
port10=38026
#查找是否存在mongod相关命令
mongod=$(which mongod)
mongo=$(which mongo)
mongos=$(which mongos)
if test -z ${mongod} -o -z ${mongo} -o -z ${mongos}
then
    echo "mongod/mongo/mongos命令未做环境变量或未安装mongod"
	exit 1
fi


###安装shard节点
#目录配置
mkdir -p /mongodb/${port5}/conf  /mongodb/${port5}/log  /mongodb/${port5}/data
mkdir -p /mongodb/${port6}/conf  /mongodb/${port6}/log  /mongodb/${port6}/data
mkdir -p /mongodb/${port7}/conf  /mongodb/${port7}/log  /mongodb/${port7}/data
mkdir -p /mongodb/${port8}/conf  /mongodb/${port8}/log  /mongodb/${port8}/data
mkdir -p /mongodb/${port9}/conf  /mongodb/${port9}/log  /mongodb/${port9}/data
mkdir -p /mongodb/${port10}/conf  /mongodb/${port10}/log  /mongodb/${port10}/data
#第一组复制集搭建：21-23（1主 1从 1Arb）
cat >  /mongodb/${port5}/conf/mongodb.conf  <<EOF
systemLog:
  destination: file
  path: /mongodb/${port5}/log/mongodb.log   
  logAppend: true
storage:
  journal:
    enabled: true
  dbPath: /mongodb/${port5}/data
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
net:
  bindIp: ${local_ip},127.0.0.1
  port: ${port5}
replication:
  oplogSizeMB: 2048
  replSetName: sh1
sharding:
  clusterRole: shardsvr
processManagement: 
  fork: true
EOF
cp  /mongodb/${port5}/conf/mongodb.conf  /mongodb/${port6}/conf/
cp  /mongodb/${port5}/conf/mongodb.conf  /mongodb/${port7}/conf/
sed "s#${port5}#${port6}#g" /mongodb/${port6}/conf/mongodb.conf -i
sed "s#${port5}#${port7}#g" /mongodb/${port7}/conf/mongodb.conf -i
#第二组节点：24-26(1主1从1Arb)
cat > /mongodb/${port8}/conf/mongodb.conf <<EOF
systemLog:
  destination: file
  path: /mongodb/${port8}/log/mongodb.log   
  logAppend: true
storage:
  journal:
    enabled: true
  dbPath: /mongodb/${port8}/data
  directoryPerDB: true
  wiredTiger:
    engineConfig:
      cacheSizeGB: 1
      directoryForIndexes: true
    collectionConfig:
      blockCompressor: zlib
    indexConfig:
      prefixCompression: true
net:
  bindIp: ${local_ip},127.0.0.1
  port: ${port8}
replication:
  oplogSizeMB: 2048
  replSetName: sh2
sharding:
  clusterRole: shardsvr
processManagement: 
  fork: true
EOF
cp  /mongodb/${port8}/conf/mongodb.conf  /mongodb/${port9}/conf/
cp  /mongodb/${port8}/conf/mongodb.conf  /mongodb/${port10}/conf/
sed "s#${port8}#${port9}#g" /mongodb/${port9}/conf/mongodb.conf -i
sed "s#${port8}#${port10}#g" /mongodb/${port10}/conf/mongodb.conf -i
#启动mongod分片集群
${mongod} -f  /mongodb/${port5}/conf/mongodb.conf 
${mongod} -f  /mongodb/${port6}/conf/mongodb.conf 
${mongod} -f  /mongodb/${port7}/conf/mongodb.conf 
${mongod} -f  /mongodb/${port8}/conf/mongodb.conf 
${mongod} -f  /mongodb/${port9}/conf/mongodb.conf 
${mongod} -f  /mongodb/${port10}/conf/mongodb.conf 

#检查上面的配置是否成功
num=$(ps -ef | grep "mongod" | wc -l)
if [ ${num} -lt 7 ]
then
	echo "mongod分片集群配置失败，请检查"
	exit 2
fi
###第一个shard节点配置
${mongo} --port ${port5} <<EOF
use  admin
config = {_id: 'sh1', members: [
                          {_id: 0, host: "${local_ip}:${port5}"},
                          {_id: 1, host: "${local_ip}:${port6}"},
                          {_id: 2, host: "${local_ip}:${port7}","arbiterOnly":true}]
           }
rs.initiate(config)
EOF
###第二个shard节点配置
${mongo} --port ${port8} <<EOF
use admin
config = {_id: 'sh2', members: [
                          {_id: 0, host: "${local_ip}:${port8}"},
                          {_id: 1, host: "${local_ip}:${port9}"},
                          {_id: 2, host: "${local_ip}:${port10}","arbiterOnly":true}]
           }
rs.initiate(config)
EOF

###config节点配置
#目录创建
mkdir -p /mongodb/${port2}/conf  /mongodb/${port2}/log  /mongodb/${port2}/data
mkdir -p /mongodb/${port3}/conf  /mongodb/${port3}/log  /mongodb/${port3}/data
mkdir -p /mongodb/${port4}/conf  /mongodb/${port4}/log  /mongodb/${port4}/data

#修改配置文件：
cat > /mongodb/${port2}/conf/mongodb.conf <<EOF
systemLog:
  destination: file
  path: /mongodb/${port2}/log/mongodb.conf
  logAppend: true
storage:
  journal:
    enabled: true
  dbPath: /mongodb/${port2}/data
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
net:
  bindIp: ${local_ip},127.0.0.1
  port: ${port2}
replication:
  oplogSizeMB: 2048
  replSetName: configReplSet
sharding:
  clusterRole: configsvr
processManagement: 
  fork: true
EOF
cp /mongodb/${port2}/conf/mongodb.conf /mongodb/${port3}/conf/
cp /mongodb/${port2}/conf/mongodb.conf /mongodb/${port4}/conf/
sed "s#${port2}#${port3}#g" /mongodb/${port3}/conf/mongodb.conf -i
sed "s#${port2}#${port4}#g" /mongodb/${port4}/conf/mongodb.conf -i

#启动节点，并配置复制集
${mongod} -f /mongodb/${port2}/conf/mongodb.conf 
${mongod} -f /mongodb/${port3}/conf/mongodb.conf 
${mongod} -f /mongodb/${port4}/conf/mongodb.conf 


num=$(ps -ef | grep "mongod" | wc -l)
if [ ${num} -lt 10 ]
then
	echo "mongod复制集配置失败，请检查"
	exit 3
fi

${mongo} --port ${port2} <<EOF
use  admin
 config = {_id: 'configReplSet', members: [
                          {_id: 0, host: "${local_ip}:${port2}"},
                          {_id: 1, host: "${local_ip}:${port3}"},
                          {_id: 2, host: "${local_ip}:${port4}"}]
           }
rs.initiate(config)  
EOF

###mongos节点配置：
#创建目录：
mkdir -p /mongodb/${port1}/conf  /mongodb/${port1}/log 

#配置文件：
cat > /mongodb/${port1}/conf/mongos.conf <<EOF
systemLog:
  destination: file
  path: /mongodb/${port1}/log/mongos.log
  logAppend: true
net:
  bindIp: ${local_ip},127.0.0.1
  port: ${port1}
sharding:
  configDB: configReplSet/${local_ip}:${port2},${local_ip}:${port3},${local_ip}:${port4}
processManagement: 
  fork: true
EOF

#启动mongos
${mongos} -f /mongodb/${port1}/conf/mongos.conf


#分片集群添加节点
${mongo} ${local_ip}:${port1}/admin <<EOF
db.runCommand( { addshard : "sh1/${local_ip}:${port5},${local_ip}:${port6},${local_ip}:${port7}",name:"shard1"} )
db.runCommand( { addshard : "sh2/${local_ip}:${port8},${local_ip}:${port9},${local_ip}:${port10}",name:"shard2"} )
EOF

num=$(ps -ef | grep "mongod" | wc -l)
if [ ${num} -lt 11 ]
then
	echo "mongos配置失败，请检查"
	exit 4
fi

echo -e "\e[5;31m该分片集群并未做任何分片测试和开启任何分片\e[0m"
