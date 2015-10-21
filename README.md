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

- Access to enough virtual resources to run a minimum of (3) machines or 'footlockers'
    - What's a footlocker?  It's a host that is capable of running cnvm's
  - Each machine will need a minimum of 1 CPU, 1 gb of memory and 30gb of disk space
  - The scripts currently support the following hypervisors and cloud providers:
    - VMWare Fusion
    - VMWare Workstation
    - Virtualbox
    - Amazon 
    - Google Compute
    - Microsoft Azure
    - Digital Ocean
  - They can live anywhere literally as long as they can see each other (details below)
- Vagrant installed on your workstation (current version required: 1.7.4)
- git installed on your workstation
- About 30 minutes of clock time (varies based on internet speeds and computing resources) 
- <b>NOTE:</b> this project currently leverages highly experimental code and local forks - we will incorporate the mainstream changes as the functionality surfaces in the community.

-----

#### Let's Do It!

- Each of the target cnvm footlockers must be able to reach each other over 22/tcp, 6783/tcp and 6783/udp. 
 - If you are running on a public cloud provider, make sure you have setup access to allow these ports and protocols

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


