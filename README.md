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

- N number of Ubuntu 15.04 64bit hosts (Minimum of 2 - one master, and at least one target node)
  - They can live anywhere literally as long as they can see each other (details below)
- Internet access
- About 30 minutes of clock time (varies based on internet speeds) 
- <b>NOTE:</b> this project currently leverages highly experimental code and local forks - we will incorporate the mainstream changes as the functionality surfaces in the community.

-----

#### Let's Do It!

We'll use a Docker container running [Ansible](http://ansible.com) to configure our nodes. Alternatively, the playbook can be run directly if you've got Ansible 1.9.3 handy.  All nodes are expected to use the same SSH key.
>**Note**: Configuration requires the root user's SSH key. If you're using AWS or another provider that doesn't make root the default user, set up a key for root now and use that for these steps.
1. Pull the deployment container from DockerHub: `docker pull gonkulatorlabs/cnvm`
2. Run the container with the following flags:
    -  `-v /path/to/ROOT/ssh/key:/keys/priv` | Map the node's **root** ssh key to `/keys/priv`
    -  `-v /path/to/ROOT/ssh/key.pub:/keys/pub` | Map the node's **root** ssh public key to `/keys/pub`
    -  `-e NODES=1.1.1.1,2.2.2.2,3.3.3.3` | Set `NODES` to a comma-separated list of IP addresses
    -  The full command should look something like this:
        ```
        docker run --rm \
        -v $HOME/.ssh/id_rsa:/keys/priv \
        -v $HOME/.ssh/id_rsa.pub:/keys/pub \
        -e NODES=1.1.1.1,2.2.2.2 gonkulatorlabs/cnvm
        ```

3. Once the deployment is complete, use the same root ssh key to log into any node as the cnvm user. On login the first cnvm will automatically launch and the current node will act as the master.  When the script completes, you can connect to it from the node at the following IP: `10.100.101.111`.

    ```shell
    cnvm@masternode~$ ssh user@10.100.101.111
    ```
    The password is 'password'

4. Open a second ssh session to the master node.  And teleport (live-migrate) it to one of the other nodes.  To do this simply:

    ```shell
    cnvm@masternode~$ teleport sneaker01.gonkulator.io cnvm@<targethost>:/home/cnvm/sneakers
    ```
  - This will initiate a live-migration of the cnvm from the master node, to the target node you specified on the command line.
  - When this executes - your ssh session on the cnvm (10.100.101.111) will become unresponsive. As soon as the migration has completed, it will resume since it has been migrated with all of its state to the target node!

5. Congratulations - you live-migrated a running cnvm!