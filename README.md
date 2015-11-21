#cnvm

**C**loud **N**ative **V**irtual **M**achine

A cnvm is a cloud native virtual machine, that is to say, a virtual machine that is as portable as a container.

[![CNVM GlobeTrotter Demo Video](http://img.youtube.com/vi/XWYcFxNaNnk/0.jpg)](http://www.youtube.com/watch?v=XWYcFxNaNnk)

**WARNING EXPERIMENTAL:**  We are not suggesting this be used in production, yet.  We are adding functionality all the time.  Please help us make it better!

The Cloud Native VM platform allows you to deploy Virtual Machines that are:
 
- Vendor-Agnostic
- Cloud-Agnostic
- Agile (dynamic, fluid, etc.)
- Software Defined (compute, networking, storage, etc.)
- Persistent
- Identical
- Secure
- Open and Shared

**cnvm is made possible by many outstanding open-source projects including:**

- Linux
- [RUNC](https://github.com/opencontainers/runc)
- [CRIU](http://www.criu.org)
- [Weave](http://weave.works)
- [Docker](http://docker.io)  - particularly @boucher 's current cr-combined fork
- [Phusion](https://github.com/phusion/baseimage-docker)

<sub>(P.S. btw - you can execute hot / cold migrations of cnvm's as well as 'classic' microservice containers)</sub>  
<sub>(P.P.S. sneakers was the internal project name for this effort - hence why you see it in the docs/vids/code)</sub>

-----

#Scripts

###We have put together a set of scripts that will build it for you on most hypervisors and cloud providers

[hybrid-cloud method: Transport a **cnvm** between Virtualbox and AWS](#hybrid-cloud-method)

[n-node-cloud method: Transport a **cnvm** between the N-nodes within the provider of your choosing](#n-node-method)

-----

#hybrid-cloud-method

***If you want to try CNVM out using the automated hybrid-cloud creator (using Virtualbox and AWS):***

**hybrid-cloud-method minimum requirements:**

- A Linux or Mac OSX workstation
  - 2 gb of available memory, 20gb of available disk space
- Vagrant installed on your workstation (current version required: 1.7.4)
- Virtualbox installed on your workstation
- The git client installed on your workstation
- An AWS account
  - An AWS security group configured to allow the following ports: 22/tcp, 6783/tcp, and 6783/udp, from the world

----

#### Let's get started with the hybrid-cloud-method! (note you can replace aws with any provider in the below example as long as you have the environment variables configured appropriately)

1. Set the following environment variables to reflect the correct settings for your AWS account

  ```
  export AWS_AMI=<UBUNTU 15.04 Vivid x64 Server AMI IMAGE in your region> - I used ami-01729c45 in US-WEST
  export AWS_REGION=<AWS REGION>
  export AWS_SECURITYGROUP=<VPC SECURITY GROUP>
  export AWS_INSTANCE=t2.medium
  export AWS_KEYPATH=<PATH TO YOUR .PEM FILE THAT MATCHES YOUR AWS_KEYNAME BELOW>
  export AWS_KEYNAME=<SSH KEY PAIR NAME>
  export AWS_ACCESS_KEY=<AWS ACCESS KEY>
  export AWS_SECRET_KEY=<AWS SECRET KEY>
  ```
2. Clone the cnvm repo on your workstation:

   *user@workstation:~$:* ```git clone https://github.com/gonkulator/cnvm.git```
3. Change into the cnvm directory, and execute the boostrap script as follows:

   *user@workstation:~$:* `cd cnvm`
 
   *user@workstation:~/cnvm$:* `./footlocker-bootstrap.sh hybrid-demo virtualbox aws`

4. This will kick off the build of 3 hosts.  A build host (in virtualbox, in your workstation), and two footlockers (one in virtualbox and one up at AWS).  A footlocker is a host that is prepped to host cnvms.  This step will take approximately 10 minutes depending on your local workstation horsepower and network connectivity.  When completed you will be returned to the prompt, and you may then log into cnvm-host-01 to deploy your first cnvm:

   *user@workstation~/cnvm$:* `vagrant ssh cnvm-host-01`

5. You will be greeted with an Ubuntu banner, and you need to su to the 'cnvm' user in order to establish the network overlay and launch the initial cnvm.  A script to do this will fire automatically upon a successful `su`.  When complete you will be notified of its ip address, password to connect, and that it is online.  

 ```
 Welcome to Ubuntu 15.04 (GNU/Linux 3.19.0-15-generic x86_64)

 * Documentation:  https://help.ubuntu.com/
 ----------------------------------------------------------------
   Ubuntu 15.04                                built 2015-10-04
 ----------------------------------------------------------------
 vagrant@cnvm-host-01:~$ sudo su - cnvm
 [o] Starting weave on 172.17.8.101
 Unable to find image 'weaveworks/weaveexec:1.1.2' locally
 1.1.2: Pulling from weaveworks/weaveexec
 511136ea3c5a: Pulling fs layer
 c9fa955c112e: Pulling fs layer
 296b35397bd8: Pulling fs layer
 5c0137366a00: Pulling fs layer
 >>TEXT CLIPPED FOR BREVITY<<<
 Status: Downloaded newer image for stlalpha/myphusion:stockticker
 [o] Attaching global hostname and IP sneaker01.gonkulator.io/10.100.101.111/24
 10.100.101.111
 [o] Setting cnvm hostname
 [o] Success
 [o] cnvm online @ 10.100.101.111/24
 Forwarding local port 22 to 10.100.101.111:2222
 Forwarding local port 80 to 10.100.101.111:8080
 Initial cnvm online @ 10.100.101.111 -- Connect with ssh: ssh user@10.100.101.111 password: password
 cnvm@cnvm-host-01:~/cnvm$
 ```

6. You have successfully launched your first cnvm! 
   Log into it by *ssh'ing* to: `10.100.101.111`

   *cnvm@cnvm-host-01:~/cnvm$* `ssh user@10.100.101.111`
   
   *password:* `password`
   
 ```
 The authenticity of host '10.100.101.111 (10.100.101.111)' can't be established.
 ECDSA key fingerprint is 4a:c8:c8:f8:19:29:3f:f4:80:de:e6:38:bc:e7:e5:e5.
 Are you sure you want to continue connecting (yes/no)? yes
 Warning: Permanently added '10.100.101.111' (ECDSA) to the list of known hosts.
 user@10.100.101.111's password:
 Last login: Sun Sep 13 17:13:06 2015 from 172.17.42.1
 user@sneaker01:~$
 ```
 
7.  Leave that terminal window logged in, and open another terminal window. Use vagrant to connect to cnvm-host-01 again, and then `su` to `cnvm`

    *user@workstation:~$* `cd cnvm`
    
    *user@workstation:~/cnvm$* `vagrant ssh cnvm-host-01`
 ```
 Welcome to Ubuntu 15.04 (GNU/Linux 3.19.0-15-generic x86_64)       

  * Documentation:  https://help.ubuntu.com/ 
 ----------------------------------------------------------------
   Ubuntu 15.04                                built 2015-10-04
 ----------------------------------------------------------------
 ```
    *vagrant@cnvm-host-01:~$* `sudo su - cnvm`
 ```
 cnvm@cnvm-host-01:~$
 ```

8. From this new session, you are going to live migrate *(teleport)* your cnvm from your Virtualbox instance, into AWS - by executing: 

   *cnvm@cnvm-host-01:~$* `teleport sneaker01.gonkulator.io cnvm@10.100.101.2:/home/cnvm/sneakers`

9. As the command executes, you will notice that in your first terminal window (the one logged into the cnvm) the session becomes unresponsive since time has frozen and it is being transported across the network to AWS.  Fear not - it will come alive again once it has reached the far side.  You will see the following in the teleport terminal session:

 ```
 cnvm@cnvm-host-01:~/cnvm$ teleport sneaker01.gonkulator.io cnvm@10.100.101.2:/home/cnvm/sneakers
 [o] Checking remote site
 [o] Checking remote landing-zone...
 Warning: Permanently added '10.100.101.2' (ECDSA) to the list of known hosts.
 [o] Remote landing zone OK
 [o] Sanitizing site
 [o] Sanitizing cnvm@10.100.101.2
 [o] Snapshotting sneaker: 638f6c319bc06148afc5f8ca01e0890522b1e6643aefe656ccedc1f9d74de167
 [o] Setting up local landing-zone...
 [o] Checkpointing sneaker 638f6c319bc06148afc5f8ca01e0890522b1e6643aefe656ccedc1f9d74de167
 [o] Checkpoint success...
 [o] Registering sneaker image...
 [o] Streaming sneaker image...
 [o] Streaming sneaker image COMPLETE
 [o] Teleporting sneaker: 638f6c319bc06148afc5f8ca01e0890522b1e6643aefe656ccedc1f9d74de167
 [o] Transferring machine state information....
 [o] Machine state information transfer COMPLETE
 [o] Creating remote surrogate...
 [o] Remote surrogate creation de3036ef6df035377b2996283af7f87bbbf0ce57547618058638553b43bdc336 COMPLETE
 [o] Restoring instance run state...
 [o] Instance run state restoration COMPLETE
 [o] Updating remote native IP addr and routes
 [o] Updating remote native IP addr and routes COMPLETE
 [o] Bringing up Weave sneaker-LAN.....
 10.100.101.111
 10.100.101.111
 10.100.101.111
 [o] Weave sneaker-LAN ONLINE
 [o] Instance teleportation COMPLETE
 [o] New sneaker id: de3036ef6df035377b2996283af7f87bbbf0ce57547618058638553b43bdc336
 [o] New native IP ADDR: 172.17.0.4
 [o] Weave SLAN IP ADDR: 10.100.101.111/24
 [o] Cleaning up...
 638f6c319bc06148afc5f8ca01e0890522b1e6643aefe656ccedc1f9d74de167
 [o] DONE
 cnvm@cnvm-host-01:~/cnvm$
 ```

10. Your cnvm terminal window will now be responsive again, the session never died, and your cvnm is now live in AWS!

***You just live-migrated a cnvm from your local workstation, wherever that is in the world, to AWS, wherever you defined in the world, without losing any state information.  The cpu, memory, disk and network states were all transferred!***

-----

#n-node-method

***Want to setup your own N-node test environment on the provider of your choice and play with it?***

**n-node-method minimum requirements:**

- A Linux or Mac OSX workstation
- Vagrant installed on your workstation (current version required: 1.7.4)
- Access to enough virtual resources (not necessarily on the local workstation) to run a minimum of (3) 'footlockers'
    - <b>What's a footlocker?</b>  It's a host that is capable of running cnvm's
  - Each footlocker will need a minimum of 1 CPU, 1 gb of memory and 30gb of disk space
  - The scripts currently build footlockers on the following hypervisors and cloud providers:
    - VMware Fusion (local workstation)
    - VMware Workstation (local workstation)
    - Virtualbox (local workstation)
    - Amazon 
    - Google Compute
    - Microsoft Azure
    - Digital Ocean
  - As long as they can see each other over the network, they can reside anywhere (details below)
- About 40 minutes of clock time (varies based on internet speeds and computing resources) 
- **NOTE:** this project currently leverages highly experimental code and local forks - we will incorporate the mainstream changes as the functionality surfaces in the community.

-----

#### Let's get started with the n-cloud-method!

- Decide which hypervisor and/or cloud providers you are going to use as your footlockers
- If you have chosen cloud providers, make sure that you have your account credentials and the other relevant environment variables set (see below for cloud-provider specific details ***BEFORE*** continuing.) 
- Each of the target cnvm footlockers must be able to reach each other over ports 22/tcp, 6783/tcp, and 6783/udp. 
 - If you are running on a public cloud provider, make sure you have set up access to allow these ports and protocols from the world

1. On your workstation, clone this repo to a local directory:

    `git clone https://github.com/gonkulator/cnvm.git`
    
2. Execute the bootstrap script passing in the argument for the provider you wish to build against and the number of footlocker nodes (remember that one will be the build node, so you will end up with N - 1 usable footlocker nodes)

    -  The full command should look something like this:

        *user@workstation~$* `cd cnvm`
        
        *user@workstation~$* `./footlocker-bootstrap.sh aws 3`
        
        **NOTE:** the script will accept the following as valid arguments: [aws](#aws), [azure](#azure), [digital_ocean](#digitalocean), [google](#google), virtualbox, vmware_fusion, vmware_workstation - execute footlocker-bootstrap.sh for more usage information.

3. Once the deployment is complete, use vagrant to log into cnvm-host-001 (or any footlocker node other than cnvm-host-00) and then `su` to the `cnvm` user. On successful `su`, the first cnvm will automatically launch.  

    *user@workstation~$* `vagrant ssh cnvm-host-01`
    
    *root@cnvm-host-01#* `sudo su - cnvm`

4. When the script completes, you can connect to the running cnvm from the footlocker at the following IP: `10.100.101.111`.

    *cnvm@cnvm-host-01~$* `ssh user@10.100.101.111`
    
    *password:* `password`
    
5. Open a second ssh session to the cnvm footlocker node.  And teleport *(live-migrate)* it to one of the other nodes.  To do this simply:

    *cnvm@cnvm-host-01~$* `teleport sneaker01.gonkulator.io cnvm@<targetip>:/home/cnvm/sneakers`
    
    **NOTE:** The target IP address in the above example can be the weave ip address of the footlocker host in question.  The hosts are numbered starting at 10.100.101.1 (cnvm-host-01) and upwards for each additional footlocker node. In the above example - cnvm-host-02 would be 10.100.101.2

  - This will initiate a live-migration of the cnvm from the master node, to the target node you specified on the command line.
  - When this executes - your ssh session on the cnvm (10.100.101.111) will become unresponsive. As soon as the migration has completed, it will resume since it has been migrated with all of its state to the target node!

5. Congratulations - you live-migrated a running cnvm!


-----

##Cloud Provider-Specific Setups

Read the details below for the provider you want to use.  

Set these environment variables **BEFORE** running footlocker-bootstrap.sh.

#aws

- You need a set of access credentials with access to a vpc and region for you to deploy.  The AWS_SECURITYGROUP that you select should have port 22/tcp, 6783/tcp, and 6783/udp open for connectivity from the world.


- You need to have the following environmental variables set:

```
export AWS_KEY=<INSERT VALUE HERE>
export AWS_AMI=<UBUNTU 15.04 Vivid x64 Server AMI IMAGE in your region> - I used ami-01729c45 in US-WEST
export AWS_REGION=<AWS REGION>
export AWS_SECURITYGROUP=<VPC SECURITY GROUP>
export AWS_INSTANCE=<INSTANCE TYPE>t2.medium
export AWS_KEYPATH=<PATH TO YOUR .PEM FILE THAT MATCHES YOUR AWS_KEYNAME BELOW>
export AWS_KEYNAME=<SSH KEY PAIR NAME>
export AWS_ACCESS_KEY=<AWS ACCESS KEY>
export AWS_SECRET_KEY=<AWS SECRET KEY>
```

#azure

- You will need to have created an Azure Management Certificate and uploaded it to Azure.  See [this link](https://github.com/Azure/vagrant-azure) for specific instructions on how to generate a management certificate.  You will also need your Azure Subscription ID.  You will need to have tcp endpoints created to allow 22/tcp, 6783/tcp, and 6783/udp access from the world.

- You will need the following environment variables set:

```
export AZURE_MGMT_CERT=<PATH TO MANAGENT CERT FILE>
export AZURE_MGMT_ENDPOINT='https://management.core.windows.net'
export AZURE_SUB_ID=<AZURE SUBSCRIPTION ID>
export AZURE_DEPLOYMENT_NAME='gonkcnvm'
export AZURE_LOCATION=<AZURE LOCATION - I used 'Central US'>
export AZURE_STORAGE_ACCT='gonk2'
export AZURE_VM_IMAGE='b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-15_04-amd64-server-20151021-en-us-30GB'
export AZURE_SSH_PRIV_KEY=<PATH TO AZURE RSA PRIV KEY YOU WANT TO USE FOR LOGIN>
export AZURE_PRIV_KEY=<PATH TO AZURE RSA PRIV KEY YOU WANT TO USE FOR LOGIN>
export AZURE_CERT_FILE=<PATH TO AZURE RSA PRIV KEY YOU WANT TO USE FOR LOGIN>
export AZURE_VM_SIZE='Standard_D1'
```

#digitalocean

- You need to create an access token from the administrative login.

- You need the following environment variables set:

```
export DO_OVERRIDE_KEY=<PATH TO SSH KEY YOU WISH TO USE>
export DO_SIZE=2GB
export DO_REGION=<DATACENTER YOU WANT TO USE - I USED NY3 FOR TESTING>
export DO_IMAGE=ubuntu-15-04-x64
export DO_TOKEN=<YOUR DIGITAL OCEAN API TOKEN>
```

#google

- You need to create a project and give it access to the Google Compute API and your client email address.  You will setup a service account that has compute access API - thats the GC_CLIENT_EMAIL that you enter below.  When setting up the API access you will create a client KEY to identify you - and that file is what you reference below as GC_KEY_LOCATION.  You need to have a firewall rules set on the project's default network that allow 22/tcp, 6783/tcp, and 6783/udp from the world. 

- You will need the following environment variables set:

```
export GC_PROJECT=<PROJECT NAME>
export GC_CLIENT_EMAIL=<CLIENT EMAIL>
export GC_KEY_LOCATION=<PATH TO API ACCOUNT CERT FILE DESCRIBED ABOVE>
export GC_IMAGE='ubuntu-1504-vivid-v20150911'
export GC_OVERRIDE_KEY=<THE SSH KEY YOU WANT TO USE TO LOGIN TO THE MACHINES>
export GC_MACHINETYPE='n1-standard'
```
