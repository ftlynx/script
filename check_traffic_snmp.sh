#!/bin/bash
#
#Time     : 2014-06-23
#Author   : ftlynx
#Function : use NET-SNMP get NIC traffic on nagios.

script=$0

Usage(){
	echo "Usage: $script [options]"
	echo "     -H     Host IP."
	echo "     -P     net-snmp community string."
	echo "     -N     NIC name."
	echo "     -W     nagios warn value. Format: 200,300.  200 is in traffic. 300 is out traffic. Unit:Kb. Default: 5000,5000"
	echo "     -C     nagios crit value. Reference -W. Default: 10000,10000"
	echo "     -V     net-snmp version. Default 2c."
	exit 2
}

DefaultValue(){
	if [ -z "$IP" -o -z "$nicdesc" -o -z "$community" ];then
		echo -e "Error: Parameter not enough.\n"
		Usage $script
	fi
	if [ -z "$warn" ];then
		warn="5000,5000"
	fi
	if [ -z "$crit" ];then
		crit="10000,10000"
	fi
	if [ -z "$version" ];then
		version=2c
	fi
}

GetResult(){
	while [ 1 ]
	do
		index=`snmpwalk -v $version -c $community $IP IF-MIB::ifDescr | grep "${nicdesc}$" |awk -F '.' '{print $2}' |awk '{print $1}'`
		if [ -z "$index" ];then
			continue
		else
			break
		fi
	done
	tempfile="/tmp/traffic.${IP}-$index"
	
	while [ 1 ]
	do
		if [ -f "$tempfile" ];then
			value=`cat $tempfile`
			last_time=`echo "$value" | awk '{print $1}'`
			last_in_traffic=`echo "$value" |awk '{print $2}'`
			last_out_traffic=`echo "$value" |awk '{print $3}'`

			now_time=`date +%s`
			now_in_traffic=`snmpwalk -v $version -c $community $IP IF-MIB::ifInOctets.${index} |awk '{print $NF}'`
			now_out_traffic=`snmpwalk -v $version -c $community $IP IF-MIB::ifOutOctets.${index} |awk '{print $NF}'`
			
			if [ -z "$now_in_traffic" -o -z "$now_out_traffic" ];then
				sleep 10
				continue
			fi

			in_traffic=$(($now_in_traffic - $last_in_traffic))
			out_traffic=$(($now_out_traffic - $last_out_traffic))
			second=$(($now_time - $last_time))
		else
			now_time=`date +%s`
			now_in_traffic=`snmpwalk -v $version -c $community $IP IF-MIB::ifInOctets.${index} |awk '{print $NF}'`
			now_out_traffic=`snmpwalk -v $version -c $community $IP IF-MIB::ifOutOctets.${index} |awk '{print $NF}'`
			if [ -z "$now_in_traffic" -o -z "$now_out_traffic" ];then
				sleep 10
				continue
			fi
			in_traffic=0
			out_traffic=0
		fi

		echo "$now_time $now_in_traffic $now_out_traffic" > $tempfile
		if [ $? -ne 0 ];then
			echo "$tempfile write fail."
				exit 2
		fi

		if [ $in_traffic -le 0 -o $out_traffic -le 0 ];then
			sleep 10
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

while getopts H:P:N:W:C:V: args
do
	case $args in
		H)
			IP="$OPTARG"
			;;
		P)
			community="$OPTARG"
			;;
		W)
			warn="$OPTARG"
			;;
		C)
			crit="$OPTARG"
			;;
		V)
			version="$OPTARG"
			;;
		N)
			nicdesc="$OPTARG"
			;;
		?)
		Usage $script
	esac
done
DefaultValue
GetResult
