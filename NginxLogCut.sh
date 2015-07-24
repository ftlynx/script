#!/bin/bash
#
#Author	: ftlynx
#Time	: 2015-01-22
#run on 23:59

#modify
Nginx=/data/nginx/sbin/nginx
NginxLogDir=/data/logs

HistoryDir="$NginxLogDir/history"
Today=`date +%Y-%m-%d-%H`

if [ ! -d "$HistoryDir" ];then
	mkdir -p $HistoryDir
fi

for file in `ls $NginxLogDir |grep \.log`
do
	mv $NginxLogDir/$file $HistoryDir/$file-$Today
done

$Nginx -s reload
find $HistoryDir -type f -mtime +30 | xargs rm -f 
