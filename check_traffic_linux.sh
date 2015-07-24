#!/bin/bash
#
#Time 	  : 2014-07-03
#Author	  : ftlynx
#Function : use "/proc/net/dev" get linux traffic. OS: Centos6.x

script=$0
datafile="/proc/net/dev"

Usage(){
	echo "Usage: $script [options]"
	echo "	-N     NIC name."
     	echo "	-W     nagios warn value. Format: 200,300.  200 is in traffic. 300 is out traffic. Unit:Kb. Default: 5000,5000"
     	echo "	-C     nagios crit value. Reference -W. Default: 10000,10000"
	exit 2
}

#check /proc/net/dev file version is correct.
VersionIsCorrect(){
	version=" face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed"
	localversion=`cat $datafile | grep "packets"`
	if [ "$localversion" != "$version" ];then
		echo "$datafile version wrong."
		exit 2
	fi
}

DefaultValue(){
	if [ -z "$nicname" ];then
		echo -e "Error: Parameter not enough.\n"
		Usage $script
	fi
	if [ -z "$warn" ];then
		warn="5000,5000"
	fi
	if [ -z "$crit" ];then
		crit="10000,10000"
	fi
}

GetValue(){
	tempfile=/tmp/traffic-$nicname
	while [ 1 ]
	do
		now_data=`cat $datafile`
		now_time=`date +%s`
		now_in_traffic=`echo "$now_data" | grep "$nicname" | awk -F ':' '{print $2}' |awk '{print $1}'`
		now_out_traffic=`echo "$now_data" | grep "$nicname" | awk -F ':' '{print $2}' |awk '{print $9}'`

		if [ -f "$tempfile" ];then
			last_data=`cat $tempfile`			
			last_time=`echo "$last_data" | awk '{print $1}'`
			last_in_traffic=`echo "$last_data" | awk '{print $2}'`
			last_out_traffic=`echo "$last_data" | awk '{print $3}'`

			in_traffic=$(($now_in_traffic - $last_in_traffic))
			out_traffic=$(($now_out_traffic - $last_out_traffic))
			second=$(($now_time - $last_time))
		else
			in_traffic=0
			out_traffic=0
		fi

		echo "$now_time $now_in_traffic $now_out_traffic" > $tempfile
		if [ $? -ne 0 ];then
			echo "Write $tempfile fail.."
			exit 2
		fi

		if [ $in_traffic -le 0 -o $out_traffic -le 0 ];then
                        sleep 3
			continue
                else
			in_result=$(($in_traffic / $second / 1024 * 8))
			out_result=$(($out_traffic / $second / 1024 * 8))	
                        break
                fi
	done

        #warn vaule
        in_warn=`echo $warn |awk -F ',' '{print $1}'`
        out_warn=`echo $warn |awk -F ',' '{print $2}'`

        #crit value
        in_crit=`echo $crit | awk -F ',' '{print $1}'`
        out_crit=`echo $crit | awk -F ',' '{print $2}'`

        echo "IN: ${in_result}Kbps[${in_warn}Kbps][${in_crit}Kbps]  OUT: ${out_result}Kbps[${out_warn}Kbps][${out_crit}Kbps] | IN=${in_result}Kb; OUT=${out_result}Kb;"
        if [ $in_result -ge $in_crit -o $out_result -ge $out_crit ];then
                exit 2
        fi
        if [ $in_result -ge $in_warn -o  $out_result -ge $out_warn ];then
                exit 1
        fi
        exit 0
}


while getopts N:W:C: args
do
        case $args in
                W)
                        warn="$OPTARG"
                        ;;
                C)
                        crit="$OPTARG"
                        ;;
                N)
                        nicname="$OPTARG"
                        ;;
                ?)
                Usage $script
        esac
done

VersionIsCorrect
DefaultValue
GetValue
