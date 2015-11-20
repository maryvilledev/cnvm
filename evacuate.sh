#!/bin/sh
args=$(docker ps | grep sneaker | awk '{print $10}')
target=$(cat target)
echo "args are: ${args}"
echo "target is: ${target}"
./parallel.sh -j 15 -r "teleport * cnvm@${target}:/home/cnvm/sneakers" ${args}