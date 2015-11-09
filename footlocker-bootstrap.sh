#!/bin/sh
#mass footlocker bootstrap - arbitrary hosts and providers
#jim@gonkulator.io 10/20/2015
#



#define functions

usage()
{
echo ""
echo "Usage: $0 provider instances"
echo "e.g., $0 aws 3"
echo "This would build a total of three nodes on AWS.  One build node and two footlocker hosts for cnvm's"
echo ""
echo "See https://github.com/gonkulator/cnvm for spceifics on configuration for each provider"
echo ""
echo "Valid provider values are:"
echo "aws - Amazon Web Services"
echo "azure - Microsoft Azure"
echo "digital_ocean - Digital Ocean"
echo "google - Google Compute Engine"
echo "virtualbox - Oracle VirtualBox"
echo "vmware_fusion - VMWare Fusion [requires addl vagrant license]"
echo "vmware_workstation - VMWare Workstation [requires addl vagrant license]"
echo ""
echo "You can also execute: $0 hybrid-demo virtualbox [aws|digital_ocean|azure|vmware_fusion|vmware_workstation|google]"
echo "This will create 3 nodes, two on virtualbox and a third on the provider of your choice to show inter-cloud/hypervisor capabilities!"
echo "See https://github.com/gonkulator/cnvm for details!"
exit 1
}


ssh_master_command()
#arg is $1 which is simply what to excute remote side - figuring out all all of the 
#necessary port information etc by poking vagrant
{
ssh -p ${masterport} -i ${mastersshkey} ${masteruser}@${masterip} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes $* 
}

scp_master_command()
#arg is $1 which is simply what to excute remote side - figuring out all all of the 
#necessary port information etc by poking vagrant
{
scp -P ${masterport} -i ${mastersshkey} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes $*
}

ssh_node_command()
{
ssh -p ${targetport} -i ${targetkey} ${targetuser}@${targetip} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes $*
}

scp_node_command()
{
scp -P ${targetport} -i ${targetkey} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes $*
}

get_host_type()
{
NODETYPE=$(vagrant status $1 | grep $1 | awk '{print $3}' | tr -d '()')
}

get_host_ssh_info()
{
	hostip=$(cat sshconfigs/$1-sshconfig | grep HostName | awk '{print $2}')
	hostuser=$(cat sshconfigs/$1-sshconfig | grep User\  | awk '{print $2}')
	hostsshkey=$(cat sshconfigs/$1-sshconfig | grep IdentityFile | awk '{print $2}')
	hostport=$(cat sshconfigs/$1-sshconfig | grep Port\  | awk '{print $2}')
}


get_host_ip()
{
	cat sshconfigs/$1-sshconfig | grep HostName | awk '{print $2}'
}

get_host_ip_virtualbox()
{
	VboxManage guestproperty get $(cat .vagrant/machines/$1/virtualbox/id) /VirtualBox/GuestInfo/Net/1/V4/IP | sed s/Value:\ //g 
}

#main

if [ $# -lt 2 ]; then
	if [ "$1" == "hybrid-demo" ]; then
		:
	else
		usage
		exit 1
	fi	
fi

#export NUM_FOOTLOCKERS=$2

#zero the host state files
touch thehosts
touch therunninghosts
>thehosts
>therunninghosts


#if we are running the split hybrid demo - create two local virtualbox instances and an AWS instance
if [ $1 = "hybrid-demo" ] ; then
	vagrant up cnvm-host-00 --provider=$2
	vagrant up cnvm-host-01 --provider=$2
	vagrant up cnvm-host-02 --provider=$3
else
	vagrant up --provider=$1
fi


#azure takes so long that vagrant times out - fix this
#vagrant reload


#mkdir the sshconfigs dir and dump all the ssh-config info into it
mkdir -p sshconfigs
for i in $(cat therunninghosts) ; do
	vagrant ssh-config ${i} > sshconfigs/${i}-sshconfig
done

#vagrant ssh-config cnvm-host-00 > sshconfigs/cnvm-host-00-sshconfig

masterip=$(cat sshconfigs/cnvm-host-00-sshconfig | grep HostName | awk '{print $2}')
masteruser=$(cat sshconfigs/cnvm-host-00-sshconfig | grep User\  | awk '{print $2}')
mastersshkey=$(cat sshconfigs/cnvm-host-00-sshconfig | grep IdentityFile | awk '{print $2}')
masterport=$(cat sshconfigs/cnvm-host-00-sshconfig | grep Port\  | awk '{print $2}')


#setup the master node, get its ssh keys and copy them local to workstation
ssh-keyscan -p ${masterport} -t rsa ${masterip} >> ~/.ssh/known_hosts 
ssh_master_command 'sudo cp id_rsa* /root/.ssh && sudo chown root /root/.ssh/id_rsa && sudo chown root /root/.ssh/id_rsa.pub'
scp_master_command ${masteruser}@${masterip}:./id_rsa* ./thekeys
echo "Retrieved cnvm-host-00 ssh-keys"

#define the target nodes (all that are not cnvm-host-00 - which is the build node)
targetnodes=($(cat therunninghosts | grep -v cnvm-host-00))


#create an array of nodes to be built/manipulated and copy the build-nodes root key to each of them and put it in ~root/.ssh/authorized_keys
echo "Target nodes are: ${targetnodes[@]}"
for i in ${targetnodes[@]}; do
	targetip=$(cat sshconfigs/$i-sshconfig | grep HostName | awk '{print $2}')
	targetuser=$(cat sshconfigs/$i-sshconfig | grep User\  | awk '{print $2}')
	targetkey=$(cat sshconfigs/$i-sshconfig | grep IdentityFile | awk '{print $2}')
	targetport=$(cat sshconfigs/$i-sshconfig | grep Port\  | awk '{print $2}')
	echo "Connecting to $i to do the key needful..."
	ssh-keyscan -p ${targetport} -t rsa ${targetip} >> ~/.ssh/known_hosts 
	ssh_node_command mkdir nodekeys
	scp_node_command ./thekeys/* ${targetuser}@${targetip}:./nodekeys
	ssh_node_command 'sudo ~/nodekeys/keyupdate.sh'
done

#build a list of targets to go ssh-keyscan based on dumping vagrant ssh-config for each node into the sshconfigs directory
keyscantargets=$(cd ./sshconfigs && for i in $(ls) ; do cat $i | grep HostName\  | awk '{print $2}' ;done | xargs)

for i in ${targetnodes[@]}; do
	targetip=$(cat sshconfigs/$i-sshconfig | grep HostName | awk '{print $2}')
	targetuser=$(cat sshconfigs/$i-sshconfig | grep User\  | awk '{print $2}')
	targetkey=$(cat sshconfigs/$i-sshconfig | grep IdentityFile | awk '{print $2}')
	targetport=$(cat sshconfigs/$i-sshconfig | grep Port\  | awk '{print $2}')
	ssh_node_command "sudo ~/nodekeys/keyscanner.sh ${keyscantargets}"
done

#copy up the keyupdate and keyscanner scripts to the master node and keyscan each of the build targets
echo "Keyscanning master to targets..."
scp_master_command thekeys/*.sh ${masteruser}@${masterip}:.
ssh_master_command "sudo ~/keyscanner.sh ${keyscantargets}"


#build the list of footlocker targets to be built based off of parsing the ssh-configs 
	echo "Kicking off Cloud Native VM footlocker builds..."
	#virtualbox is special - so get the private network ip's of the arbitrary nodes using vboxmanage and plug them in here otherwise carry on...
	#BUILDNODETYPE=$(get_host_type cnvm-host-00)
	targetnodeips=($(for i in ${targetnodes[@]}; do get_host_type ${i} ; if [ "$NODETYPE" == virtualbox ] ; then get_host_ip_virtualbox ${i} ; else get_host_ip ${i} ; fi ; done))
	footlockertargets=$(echo ${targetnodeips[@]} | sed s/\ /,/g)

#ssh into the build node and pull the ansible container that will bootstrap all the footlocker hosts
echo "Pulling build container...."
ssh_master_command "docker pull gonkulatorlabs/cnvm:vagrant-multi"
echo "Building...."
#ssh into the build node and execute the ansible container with the NODES arg set to the footlocker targets list yoiu built above
ssh_master_command "sudo docker run -v /root/.ssh/id_rsa:/keys/priv -v /root/.ssh/id_rsa.pub:/keys/pub -e NODES=${footlockertargets} gonkulatorlabs/cnvm:vagrant-multi"

#cleanup - unless you set debug then leave the logs laying around so you can figure out whats going on
if [ "$3" != "debug" ] ; then
echo "Cleaning up..."
rm sshconfigs/*
rm thekeys/id_rsa*
rm thehosts
rm therunninghosts
echo "Done."
else
	echo "done"
fi
