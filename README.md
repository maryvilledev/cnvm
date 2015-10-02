# cnvm

<b>C</b>loud <b>N</b>ative <b>V</b>irtual <b>M</b>achine

A cnvm is a cloud native virtual machine, that is to say, a virtual machine that is as portable as a container.

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

Here's a video showing the mechanics in motion:

[![CNVM GlobeTrotter Demo Video](http://img.youtube.com/vi/XWYcFxNaNnk/0.jpg)](http://www.youtube.com/watch?v=XWYcFxNaNnk)

<b>cnvm is built on top of and from many outstanding open-source projects including:</b>

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

- N number of Ubuntu 15.04 64bit hosts (Minimum of 2 - one master, and at least one target node)
  - They can live anywhere literally as long as they can see each other (details below)
- Internet access
- About 30 minutes of clock time (varies based on internet speeds) 
- <b>NOTE:</b> this project currently leverages highly experimental code and local forks - we will incorporate the mainstream changes as the functionality surfaces in the community.

-----

**Let's Do It!:**  

1.  Create N number of Ubuntu 15.04 vm's somewhere
    - They must be able to see each other over the network on port 22/tcp, 6783/tcp, and 6783/udp  
2.  Pick a non-root username to use for the installation (in our example the username will be "user")
    - This user must be in the sudoers file
    - You need to generate (or use one that you already have) an ssh keypair and put the public key in each host's ~/.ssh/authorized\_keys file

3. Choose one of your machines to be the "master" node.  This is the machine that you will launch cnvms from.

4. Log into your master node as "user" and execute:
    ```shell
    user@host1~$ wget -qO- https://raw.github.com/gonkulator/cnvm/footlocker-bootstrap.bash | bash
    ```

5. Follow the prompts.  You will be logged out twice.  Once after Docker is installed to get you added into the "docker" group and a second time after the bootstrap configuation is complete.

6. When you log back in after Docker bootstrap is installed - you will be prompted to answer whether or not this is the master node.  Answer "y".  It will then ask you to enter your targets.  This is where you enter all of the nodes in your setup.  If you only have two (your master and another) you enter them both here.  If you have 5 (your master and 4 more) you enter all of those here.  The format is one entry per line, and its username@host.  In our example I enter:
    ```shell
    user@172.17.135.138
    user@172.17.135.139
    ```

7. The process will now install and configure the remaining software

8. While this is running, please log into each of the target nodes as your user (again, in our example, "user") and execute:
    ```shell
    user@hostX~$ wget -qO- https://raw.github.com/gonkulator/cnvm/master/footlocker-bootstrap.bash | bash
    ```

9. Follow the prompts.  You will be logged out twice.  Once after Docker is installed also adding you into the right groups and a second time after the bootstrap configuation is complete.

10. When you log back in after Docker bootstrap is installed - you will be prompted to answer whether or not this is the master node.  Answer "n"

11. The process will now install and configure the remaining software.  This takes about 15 minutes per node.  You can run them all in parallel if you would like.

12. When the processes complete, it will log you out from the master and any target nodes.  You are done with the build process, and ready to deploy your first cnvm.

13. Log into the master node, which will automatically launch the first cnvm.  When completed, you can connect to it via the master node at the following IP: 10.100.101.111.

    From the master node:
    ```shell
    user@masternode~$ ssh user@10.100.101.111
    ```
    The password is 'password'

14. Open a second ssh session to the master node.  And teleport (live-migrate) it to one of the other nodes.  To do this simply:

    ```shell
    user@masternode~$ ./teleport.sh sneaker01.gonkulator.io user@<targethost>:/home/user/sneakers
    ```
  - This will initiate a live-migration of the cnvm from the master node, to the target node you specified on the command line.
  - When this executes - your ssh session on the cnvm (10.100.101.111) will become unresponsive - but as soon as the migration has completed, it will be resume since it has been migrated with all of its state to the target node!
 
15. Congratulations - you live-migrated a running cnvm!
