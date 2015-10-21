#!/bin/sh
cat ~/nodekeys/id_rsa.pub >> /root/.ssh/authorized_keys
cp ~/nodekeys/id_rsa* /root/.ssh
