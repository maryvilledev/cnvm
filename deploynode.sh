#!/bin/bash
#Deploy the weave overlay onto the footlocker hosts
#Jim McBride jm@gonkulator.io 8/28/15

set -e

usage()
{
echo ""
echo "Usage: $0 user@host network/mask"
echo "e.g., $0 jm@server1.gonkulator.io 10.100.101.0/24"
echo ""
exit 1
}

#functions / defines

targets=($(cat targets))
export sshtarget=$1
export dsthostname=$(echo ${sshtarget} | awk -F\@ '{print $2}')
export dstusername=$(echo ${sshtarget} | awk -F\@ '{print $1}')
export clusternetwork=$2
export clusternetworknocidr=$(echo ${clusternetwork} | awk -F\/ '{print $1}')
export clusternetworkcidr=$(echo ${clusternetwork} | awk -F\/ '{print $2}')
export clusternetworknolastoctet=$(echo ${clusternetworknocidr} | awk -F. '{print $1"."$2"."$3"."}')
export PID=$$


	status() {
	echo "[o] $*"
}
	error() {
		echo "[!] ERROR: $*"
	}





#main

if  [ $# -lt 2 ] ; then
	usage
	exit 1
fi

if [ ${clusternetworkcidr} -ne 24 ] ; then
	error Sorry - currently only support /24 networks
	exit 1
fi


######

export OCTET=1

for i in ${targets[@]}; do
status Starting weave on $(echo $i | awk -F\@ '{print $2}')
#ssh ${i} "weave launch --ipalloc-range ${clusternetwork}"
ssh ${i} "weave launch" 
status Connecting $(echo $i | awk -F\@ '{print $2}') to CLAN
ssh ${i} "weave expose ${clusternetworknolastoctet}${OCTET}/24"
status Copying teleport script to $(echo $i | awk -F\@ '{print $2}'):.
scp teleport.sh ${i}:.
((OCTET++))

done

status Interconnecting nodes...

for i in ${targets[@]}; do
	if [ ${i} != "${targets[0]}" ] ; then
	status Connecting $(echo ${targets[0]} | awk -F \@ '{print $2}') to $(echo $i | awk -F\@ '{print $2}')
	#dont even ask - yes this is the most portable system resolver based fix i could come up with in 10 minutes
	ssh ${targets[0]} weave connect $(ping -t1 -c1 $(echo $i | awk -F\@ '{print $2}') | grep PING | awk '{print $3}' | sed s/[\)\(\:]//g)
	#ssh ${targets[0]} weave connect $(echo $i | awk -F\@ '{print $2}')
	else
	status "Skipping self..."
	fi
	done



