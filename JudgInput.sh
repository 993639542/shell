#!/bin/bash
#判断输入

if [ -z "`echo $1 | sed 's/[0-9]//g'`" ]
then
	echo "你输入的数字"
elif [ -z "`echo $1 | sed 's/[a-z]|[A-Z]//g'`" ]	
then
	echo "你输入的是字符"
else
	echo "你输入包含特殊字符"
fi
