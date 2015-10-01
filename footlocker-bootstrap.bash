#!/bin/bash
#footlocker-host-bootstrap.sh jm@gonkulator.io 8/22/2015
# Adam Thornton 30 September 2015

#functions

status() {
	echo "[*] $*"
}

get_targets() {
    echo "Enter target machines in form user@host; blank line when done."
    while true ; do
	read line
	l=$(echo $line | sed -e 's/^\s+//' | sed -e 's/\s+$//')
	if [ -z "${l}" ]; then
	    break
	fi
	set +e
	echo ${l} | grep -q '@'
	rc=$?
	set -e
	if [ "x${rc}" != "x0" ]; then
	    echo "[X] Targets must be entered in form user@host."
	    continue
	fi
	targets=("${targets[@]}" ${l})
    done
}

DOCKER_INSTALLED=~/.DOCKER_INSTALLED
SNEAKERCLONED=~/.SNEAKER_CLONED
set -e

if [ ! -f "${DOCKER_INSTALLED}" ]; then
#you need git - install it first
status Installing git...
sudo apt-get install git -y 2>&1 >/dev/null
status Installing base docker for bootstrapping...
sudo apt-get install docker.io -y 2>&1 >/dev/null
#flag that docker is installed now
status Starting docker...
sudo service docker start 2>&1 >/dev/null
touch ~/.DOCKER_INSTALLED
fi

if [ ! -f "${SNEAKERCLONED}" ]; then
clonesrc="git@github.com:stlalpha/cnvm.git"
status Cloning cnvm repository....
git clone ${clonesrc} 2>&1 >/dev/null
cd cnvm
#flag that you cloned the cnvm dir
touch ~/.SNEAKER_CLONED
fi


set +e
groups | grep -q docker
rc=$?
set -e
#if [ "x${rc}" != "x0" ] && [ -z "${JUSTADDED}" ]; then
if [ "x${rc}" != "x0" ] ; then
    echo "**************************"
    echo "Have to log you out in order to get you in the docker group."
    echo "Please log in again and installation will continue."
    echo "**************************"
    sudo usermod -aG docker $(logname)
    touch ~/.BOOTSTRAP_LOGOUT_FLAG
    cat <<EOF >> ~/.bash_profile
#!/bin/bash
if [ -f ~/.BOOTSTRAP_LOGOUT_FLAG ]; then 
    rm ~/.BOOTSTRAP_LOGOUT_FLAG && cat ~/.profile > ~/.bash_profile
    echo "[o] Enter target footlocker hosts (including this one)"
    echo "[o] Format is: username@host e.g., jm@172.16.157.135"
    cd cnvm && ./footlocker-bootstrap.bash

fi
EOF
    kill -HUP $PPID
    exit 
fi


echo "Will this be the master node [Y|N]?"
    read line
    master=$(echo $line | sed -e 's/^\s+//' | sed -e 's/\s+$//' | cut -c 1 | tr [:upper:] [:lower:] )
    if [ ${master} == "y" ]; then

declare -a targets
get_targets
now=$(date +%Y%m%d%H%M%s)
if [ -f targets ]; then
    mv targets targets.${now}
fi
printf "%s\n" "${targets[@]}" > targets
    fi



#prep host packages
set +e
status Preparing host packages...
sudo apt-get update -y 2>&1 >/dev/null
status apt-get upgrading...
sudo apt-get upgrade -y 2>&1 >/dev/null
status Installing pre-req packages for build activities...
sudo apt-get install -y build-essential libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf curl 2>&1 >/dev/null
set -e
#make the dirz
status Criu download and build...
mkdir -p ~/development/src
cd ~/development/src

#grab criu and build it and install it
status Cloning criu fork...
git clone https://github.com/gonkulator/criu.git 2>&1 >/dev/null
cd ~/development/src/criu
make
status Compiling criu....
sudo make install-criu 2>&1 >/dev/null

#Go experimental
cd ~/development/src
status Cloning docker experimental fork...
git clone https://github.com/gonkulator/docker.git 2>&1 >/dev/null
cd ~/development/src/docker
git checkout fix-restore-network-cr-combined-1.9 2>&1 >/dev/null
status Compiling docker experimental....this will take some time....
status Compile time varies but on a typical machine expect ~15 minutes
status I am going to turn on stdout so you can see that the process is moving and not hung...
status -- pausing for 10 seconds so you can read this message ---
sleep 10
make DOCKER_EXPERIMENTAL=1 binary
#stop the docker service
status Stopping docker bootstrap...
sudo service docker stop 2>&1 >/dev/null
#copy new binary
status Updating docker bin...
sudo install -m 0755 bundles/1.9.0-dev/binary/docker /usr/bin/docker 2>&1 >/dev/null
#start new docker
status Starting docker experimental...
sudo service docker start 2>&1 >/dev/null
#install weave
cd ~/development/src
mkdir -p weave
cd weave
status Installing weave...
curl -L git.io/weave -o weave 2>&1 >/dev/null
sudo install -m 0755 weave /usr/local/bin/weave 2>&1 >/dev/null
sync
sleep 2
mkdir -p ~/sneakers
if [ ${master} == "y" ]; then 
    status Master node: setting up .bash_profile to execute sneaker deployment on reboot...
    cat <<EOF >> ~/.bash_profile
if [ -f ~/UNCONFIGURED ]; then 
    cd cnvm && ./deploynode.sh foo 10.100.101.0/24 && ./deploysneaker.sh ${targets[0]} stlalpha/myphusion:stockticker sneaker01.gonkulator.io 10.100.101.111/24 && cd - && rm ~/UNCONFIGURED && rm ~/.SNEAKER_CLONED && rm ~/.DOCKER_INSTALLED && cat ~/.profile > ~/.bash_profile && echo "Initial cnvm online @ 10.100.101.111 -- Connect with ssh: ssh user@10.100.101.111 password: password" 
fi
EOF
    touch ~/UNCONFIGURED
fi
status Footlocker bootstrap complete!
if [ ${master} == "y" ]; then 
status Log back in to auto-deploy the first cnvm!
fi
status Rebooting node....
sudo reboot
