#!/bin/bash

if [[ -z ${NODES} ]]; then
	echo "Must supply list of \$NODES!"
	exit 1
fi

if ! [[ -f /keys/priv ]]; then
	echo "Must mount private key to /keys/priv!"
	exit 1
fi

if ! [[ -f /keys/pub ]]; then
	echo "Must mount public key to /keys/pub!"
	exit 1
fi

mkdir -p ~/.ssh /etc/ansible

cp /keys/priv ~/.ssh/id_rsa
cp /keys/pub ~/.ssh/id_rsa.pub
chmod 0400 ~/.ssh/id_rsa

echo -e "[cnvm]\n" > /etc/ansible/hosts
for node in $(echo ${NODES} | tr ',' '\n'); do
	ssh-keyscan -t rsa ${node} >> ~/.ssh/known_hosts
	echo -e "${node} ansible_ssh_host=${node}\n" >> /etc/ansible/hosts
done

cd /etc/ansible
ansible-playbook -vvvv setup.yml