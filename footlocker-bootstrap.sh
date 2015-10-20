#!/bin/sh
#dc mass footlocker bootstrap


#zero the host state files
touch thehosts
touch therunninghosts
>thehosts
>therunninghosts


vagrant up --provider=$1
#azure takes so long that vagrant times out - fix this
#vagrant reload


mkdir sshconfigs
vagrant ssh-config cnvm-host-00 > sshconfigs/cnvm-host-00-sshconfig
masterip=$(cat sshconfigs/cnvm-host-00-sshconfig | grep HostName | awk '{print $2}')
masteruser=$(cat sshconfigs/cnvm-host-00-sshconfig | grep User\  | awk '{print $2}')
mastersshkey=$(cat sshconfigs/cnvm-host-00-sshconfig | grep IdentityFile | awk '{print $2}')
masterport=$(cat sshconfigs/cnvm-host-00-sshconfig | grep Port\  | awk '{print $2}')

ssh-keyscan -p ${masterport} -t rsa ${masterip} >> ~/.ssh/known_hosts 
ssh -p ${masterport} -i ${mastersshkey} ${masteruser}@${masterip} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes 'sudo cp id_rsa* /root/.ssh && sudo chown root /root/.ssh/id_rsa && sudo chown root /root/.ssh/id_rsa.pub'
scp -P ${masterport} -i ${mastersshkey} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes ${masteruser}@${masterip}:./id_rsa* ./thekeys
echo "Retrieved cnvm-host-00 ssh-keys"

targetnodes=($(cat therunninghosts | grep -v cnvm-host-00))


echo "Target nodes are: ${targetnodes[@]}"
for i in ${targetnodes[@]}; do
	vagrant ssh-config $i > sshconfigs/$i-sshconfig
	targetip=$(cat sshconfigs/$i-sshconfig | grep HostName | awk '{print $2}')
	targetuser=$(cat sshconfigs/$i-sshconfig | grep User\  | awk '{print $2}')
	targetkey=$(cat sshconfigs/$i-sshconfig | grep IdentityFile | awk '{print $2}')
	targetport=$(cat sshconfigs/$i-sshconfig | grep Port\  | awk '{print $2}')
	echo "Connecting to $i to do the key needful..."
	ssh-keyscan -p ${targetport} -t rsa ${targetip} >> ~/.ssh/known_hosts 
	ssh -p ${targetport} -i ${targetkey} ${targetuser}@${targetip} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes mkdir nodekeys
	scp -P ${targetport} -i ${targetkey} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes ./thekeys/* ${targetuser}@${targetip}:./nodekeys
	ssh -p ${targetport} -i ${targetkey} ${targetuser}@${targetip} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes 'sudo ~/nodekeys/keyupdate.sh'
done

keyscantargets=$(cd ./sshconfigs && for i in $(ls) ; do cat $i | grep HostName\  | awk '{print $2}' ;done | xargs)

for i in ${targetnodes[@]}; do
	targetip=$(cat sshconfigs/$i-sshconfig | grep HostName | awk '{print $2}')
	targetuser=$(cat sshconfigs/$i-sshconfig | grep User\  | awk '{print $2}')
	targetkey=$(cat sshconfigs/$i-sshconfig | grep IdentityFile | awk '{print $2}')
	targetport=$(cat sshconfigs/$i-sshconfig | grep Port\  | awk '{print $2}')
	ssh -p ${targetport} -i ${targetkey} ${targetuser}@${targetip} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes "sudo ~/nodekeys/keyscanner.sh ${keyscantargets}"
done

echo "Keyscanning master to targets..."
scp -P ${masterport} -i ${mastersshkey} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes thekeys/*.sh ${masteruser}@${masterip}:.
ssh -p ${masterport} -i ${mastersshkey} ${masteruser}@${masterip} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes "sudo ~/keyscanner.sh ${keyscantargets}"

echo "Kicking off Cloud Native VM footlocker builds..."
#virtualbox is special - so get the private network ip's of the arbitrary nodes using vboxmanage - ick! - and plug them in here otherwise carry on...
if [ $1 = "virtualbox" ] ; then
	thehassle=$(for i in $(ls sshconfigs/ | grep -v cnvm-host-00 | sed s/-sshconfig//g) ; do VboxManage guestproperty get $(cat .vagrant/machines/${i}/virtualbox/id) /VirtualBox/GuestInfo/Net/1/V4/IP | sed s/Value:\ //g | xargs ; done) 
	footlockertargets=$(echo ${thehassle} | sed s/\ /,/g)
else
footlockertargets=$(cd ./sshconfigs && for i in $(ls | grep -v cnvm-host-00) ; do cat $i | grep HostName\  | awk '{print $2}' ;done | xargs | sed s/\ /,/g)
fi
echo "Pulling build container...."
ssh -p ${masterport} -i ${mastersshkey} ${masteruser}@${masterip} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes "docker pull gonkulatorlabs/cnvm"
echo "Building...."
ssh -p ${masterport} -i ${mastersshkey} ${masteruser}@${masterip} -o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes "sudo docker run -v /root/.ssh/id_rsa:/keys/priv -v /root/.ssh/id_rsa.pub:/keys/pub -e NODES=${footlockertargets} gonkulatorlabs/cnvm"

echo "Cleaning up..."
#rm sshconfigs/*
#rm thekeys/id_rsa*
#rm thehosts
#rm therunninghosts

echo "Done."
