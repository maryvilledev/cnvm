#!/bin/sh
#setup cnvm onramp from localhost to demo cnvm on the container network

echo "Forwarding local port 22 to 10.100.101.111:2222"
sudo ncat --sh-exec "ncat 10.100.101.111 22" -l 2222 --keep-open 2>&1 >/dev/null &
echo "Forwarding local port 80 to 10.100.101.111:8080"
sudo ncat --sh-exec "10.100.101.111 8000" -l 80 --keep-open 2>&1 >/dev/null &
