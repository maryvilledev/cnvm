#!/bin/sh


usage()
{
echo ""
echo "Usage: $0 user@host imagename hostname ipaddress"
echo "e.g., $0 jm@server1.gonkulator.io stlalpha/myphusion sneaker01 10.100.101.100/24"
echo ""
exit 1
}

#functions / defines

export sshtarget=$1
export dsthostname=$(echo ${sshtarget} | awk -F\@ '{print $2}')
export dstusername=$(echo ${sshtarget} | awk -F\@ '{print $1}')
export cnvmrunimage=$2
export cnvmhostname=$3
export cnvmipaddr=$4
export PID=$$



	status() {
	echo "[o] $*"
}
	error() {
		echo "[-] ERROR: $*"
	}


#main

if  [ $# -lt 4 ] ; then
	usage
	exit 1
fi

status sshtarget = ${sshtarget}
status dsthostname = ${dsthostname}
status dstusername = ${dstusername}

status Deploying cnvm hostname: ${cnvmhostname} image: ${cnvmrunimage} ipaddr: ${cnvmipaddr}
remotecontainerid=$(ssh ${sshtarget} docker run -d --name=${cnvmhostname} ${cnvmrunimage})
status Attaching global hostname and IP ${cnvmhostname}/${cnvmipaddr}
ssh ${sshtarget} weave attach ${cnvmipaddr} ${remotecontainerid}
status Setting cnvm hostname
ssh ${sshtarget} docker exec --privileged=true ${remotecontainerid} "hostname ${cnvmhostname}"
status Success	
status cnvm online @ ${cnvmipaddr}