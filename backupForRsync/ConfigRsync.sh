#!/bin/bash
#
#Author : ftlynx
#Time   : 2014-09-18

dir=/data/rsyncd
file=rsyncd.conf

value=`rpm -qa | grep rsync | grep -c rsync`
if [ $value -eq 0 ];then
	echo "rsync is not install. Please run [yum install rsync -y]"
	exit 1
fi

mkdir -p $dir
cp rsyncd.conf.example $dir/$file
cp rsyncd.pwd.example  $dir/rsyncd.pwd
chmod 600 $dir/rsyncd.pwd

echo "Please modifiy $dir/$file. Run: rsync --daemon --config=$dir/$file"
