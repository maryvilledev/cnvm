# cnvm

<b>C</b>loud <b>N</b>ative <b>V</b>irtual <b>M</b>achine

A cnvm is a cloud native virtual machine, that is to say, a virtual machine that is as portable as a container.

[![CNVM GlobeTrotter Demo Video](http://img.youtube.com/vi/XWYcFxNaNnk/0.jpg)](http://www.youtube.com/watch?v=XWYcFxNaNnk)


<b>WARNING EXPERIMENTAL:</b>  We are not suggesting this be used in production, yet.  We are adding functionality all the time.  Please help us make it better!

The Cloud Native VM platform allows you to deploy Virtual Machines that are:
 
- Vendor-Agnostic
- Cloud-Agnostic
- Agile (dynamic, fluid, etc.)
- Software Defined (compute, networking, storage, etc.)
- Persistent
- Identical
- Secure
- Open and Shared

<b>cnvm is made possible by many outstanding open-source projects including:</b>

- Linux
- [RUNC](https://github.com/opencontainers/runc)
- [CRIU](http://www.criu.org)
- [Weave](http://weave.works)
- [Docker](http://docker.io)  - particularly @boucher 's current cr-combined fork
- [Phusion](https://github.com/phusion/baseimage-docker)

<sub>(P.S. btw - you can execute hot / cold migrations of cnvm's as well as 'classic' microservice containers)</sub>  
<sub>(P.P.S. sneakers was the internal project name for this effort - hence why you see it in the docs/vids/code)</sub>

-----


***Want to setup your own N-node test environment and play with it?***

**Things You will need:**

- A Linux or Mac OSX workstation
- Vagrant installed on your workstation (current version required: 1.7.4)
- git installed on your workstation
- Access to enough virtual resources (not necessarily on the local workstation) to run a minimum of (3) 'footlockers'
    - <b>What's a footlocker?</b>  It's a host that is capable of running cnvm's
  - Each footlocker will need a minimum of 1 CPU, 1 gb of memory and 30gb of disk space
  - The scripts currently build footlockers on the following hypervisors and cloud providers:
    - VMWare Fusion (local workstation)
    - VMWare Workstation (local workstation)
    - Virtualbox (local workstation)
    - Amazon 
    - Google Compute
    - Microsoft Azure
    - Digital Ocean
  - They can live anywhere literally as long as they can see each other over the network (details below)
- About 40 minutes of clock time (varies based on internet speeds and computing resources) 
- <b>NOTE:</b> this project currently leverages highly experimental code and local forks - we will incorporate the mainstream changes as the functionality surfaces in the community.

-----

#### Let's Do It!

- Decide which hypervisor and/or cloud providers you are going to use to build your footlockers
- If you have chosen cloud providers, make sure that you have your account credentials and the other relevant environment variables set (see below for cloud-provider specific how-to details) 
- Each of the target cnvm footlockers must be able to reach each other over 22/tcp, 6783/tcp and 6783/udp. 
 - If you are running on a public cloud provider, make sure you have set up access to allow these ports and protocols

1. On your workstation, clone this repo to a local directory:

    ```
    git clone https://github.com/gonkulator/cnvm.git
    ```
2. Execute the bootstrap script passing in the argument for the provider you wish to build against and the number of footlocker nodes (remember that one will be the build node, so you will end up with N - 1 usable footlocker nodes)

    -  The full command should look something like this:

        ```
        user@workstation~$ cd cnvm
        user@workstation~$ ./footlocker-bootstrap.sh aws 3
        ```
        <b>NOTE:</b> the script will accept the following as valid arguments: aws, azure, digitalocean, google, virtualbox, vmware_fusion, vmware_workstation - execute footlocker-bootstrap.sh for more usage information.

3. Once the deployment is complete, use vagrant to log into cnvm-host-001 (or any footlocker node other than cnvm-host-00) and then su to the 'cnvm' user. On successful su, the first cnvm will automatically launch.  

    ```shell
    user@workstation~$ vagrant ssh cnvm-host-01
    root@cnvm-host-01# sudo su - cnvm
    ```

4. When the script completes, you can connect to the running cnvm from the footlocker at the following IP: `10.100.101.111`.

    ```shell
    cnvm@cnvm-host-01~$ ssh user@10.100.101.111
    ```
    The password is 'password'

5. Open a second ssh session to the cnvm footlocker node.  And teleport (live-migrate) it to one of the other nodes.  To do this simply:

    ```shell
    cnvm@cnvm-host-01~$ ./teleport.sh sneaker01.gonkulator.io cnvm@<targetipaddress>:/home/cnvm/sneakers
    ```
    <b>NOTE:</b> The target IP address in the above example can be the weave ip address of the footlocker host in question.  The hosts are numbered starting at 10.100.101.1 (cnvm-host-00) and upwards for each additional footlocker node. In the above example - cnvm-host-02 would be 10.100.101.3

  - This will initiate a live-migration of the cnvm from the master node, to the target node you specified on the command line.
  - When this executes - your ssh session on the cnvm (10.100.101.111) will become unresponsive. As soon as the migration has completed, it will resume since it has been migrated with all of its state to the target node!

5. Congratulations - you live-migrated a running cnvm!


-----

#Cloud Provider-Specific Setups

Read the details below for the provider you want to use.  Set these environment variables BEFORE running footlocker-bootstrap.sh.

##AWS

You need a set of access credentials with access to a vpc and region for you to deploy.  The AWS_SECURITYGROUP that you select should have port 22/tcp and 6783/tcp and 6783/udp open for connectivity from all nodes.


And you need to have the following environmental variables set:

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

##Digital Ocean

You need to create an access token from the administrative login.

You need the following environment variables set:

```
DO_OVERRIDE_KEY=<PATH TO SSH KEY YOU WISH TO USE>
DO_SIZE=2GB
DO_REGION=<DATACENTER YOU WANT TO USE - I USED NY3 FOR TESTING>
DO_IMAGE=ubuntu-15-04-x64
DO_TOKEN=<YOUR DIGITAL OCEAN API TOKEN>
```

##Google Compute Engine

You need to create a project and give it access to the Google Compute API and your client email address.  You will setup a service account that has compute access API - thats the GC_CLIENT_EMAIL that you enter below.  When setting up the API access you will create a client KEY to identify you - and that file is what you reference below as GC_KEY_LOCATION.  You need to have a firewall rules set on the project's default network that allow 22/tcp and 6783/tcp and 6783/udp from the world. 

You will need the following environment variables set:

```
export GC_PROJECT=<PROJECT NAME>
export GC_CLIENT_EMAIL=<CLIENT EMAIL>
export GC_KEY_LOCATION=<PATH TO API ACCOUNT CERT FILE DESCRIBED ABOVE>
export GC_IMAGE='ubuntu-1504-vivid-v20150911'
export GC_OVERRIDE_KEY=<THE SSH KEY YOU WANT TO USE TO LOGIN TO THE MACHINES>
export GC_MACHINETYPE='n1-standard'
```

##Microsoft Azure

You will need to have created an azure Management Certificate and uploaded it to Azure.  See [this link](https://github.com/Azure/vagrant-azure) for specific instructions on how to generate a management certificate.  You will also need your Azure Subscription ID.  You will need to have tcp endpoints created to allow 22/tcp, 6783/tcp and 6783/udp access from the world.

You will need the following environment variables set:

```
export AZURE_MGMT_CERT=<PATH TO MANAGENT CERT FILE>
export AZURE_MGMT_ENDPOINT='https://management.core.windows.net'
export AZURE_SUB_ID=<AZURE SUBSCRIPTION ID>
export AZURE_DEPLOYMENT_NAME='gonkcnvm'
export AZURE_LOCATION=<AZURE LOCATION - I used 'Central US'>
export AZURE_STORAGE_ACCT='gonk2'
export AZURE_VM_IMAGE='b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu_DAILY_BUILD-vivid-15_04-amd64-server-20150917-en-us-30GB'
export AZURE_SSH_PRIV_KEY=<PATH TO AZURE RSA PRIV KEY YOU WANT TO USE FOR LOGIN>
export AZURE_PRIV_KEY=<PATH TO AZURE RSA PRIV KEY YOU WANT TO USE FOR LOGIN>
export AZURE_CERT_FILE=<PATH TO AZURE RSA PRIV KEY YOU WANT TO USE FOR LOGIN>
export AZURE_VM_SIZE='Standard_D1'