#!/bin/sh
ssh-keyscan -t rsa $* >> /root/.ssh/known_hosts
