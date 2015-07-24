#!/bin/bash
#
#Author : ftlynx
#Time	: 2014-09-18

ConfigFile=backup.conf

ParseConfig(){
	if [ ! -f $ConfigFile ];then
		echo "$ConfigFile is not exists."
		exit 1
	fi	
	i=0
 	while read line
	do
		value=`echo "$line" | grep -v '^#' | grep -v '^$' |wc -l`
		if [ $value -eq 0 ];then
			continue
		fi
		arr=($line)
		LocalSrc[$i]=${arr[0]}	
		RsyncAddr[$i]=${arr[1]}
		RsyncItem[$i]=${arr[2]}
		RsyncUser[$i]=${arr[3]}
		RsyncPwd[$i]=${arr[4]}
		let i++	
	done < $ConfigFile
}

# local --> rsync server
UploadSync(){
	for((i=0;i<${#LocalSrc[@]};i++))
	do
		if [ -z "${LocalSrc[$i]}" -o -z "${RsyncAddr[$i]}" -o -z "${RsyncItem[$i]}" -o -z "${RsyncUser[$i]}" -o -z "${RsyncPwd[$i]}" ];then
			echo "Line:${LocalSrc[$i]} Having NULL Vaule."
			continue
		fi	
		export RSYNC_PASSWORD=${RsyncPwd[$i]}
		rsync -av ${LocalSrc[$i]} rsync://${RsyncUser[$i]}@${RsyncAddr[$i]}/${RsyncItem[$i]}
		Rstatus[$i]=$?
	done
}

# rsync server --> local
DownloadSync(){
	for((i=0;i<${#LocalSrc[@]};i++))
        do
                if [ -z "${LocalSrc[$i]}" -o -z "${RsyncAddr[$i]}" -o -z "${RsyncItem[$i]}" -o -z "${RsyncUser[$i]}" -o -z "${RsyncPwd[$i]}" ];then
                        echo "Line:${LocalSrc[$i]} Having NULL Vaule."
                        continue
                fi
                export RSYNC_PASSWORD=${RsyncPwd[$i]}
                rsync -av rsync://${RsyncUser[$i]}@${RsyncAddr[$i]}/${RsyncItem[$i]} ${LocalSrc[$i]}
                Rstatus[$i]=$?
        done
}

#check return value
CheckReturnValue(){
        for((i=0;i<${#LocalSrc[@]};i++))
        do
                if [ ${Rstatus[$i]} -ne 0 ];then
                        echo "${LocalSrc} ${Rstatus[$i]} ${Rcontent[$i]}"
                fi
        done
}


ParseConfig
UploadSync
