#!/bin/bash
#export ip=100
##for i in 1 2 3 4 5 6 7 8 9 ; do
#count = 1
#while [ count -lt 10 ] ; do
#deploysneaker cnvm@10.100.101.${i} stlalpha/myphusion:stockticker 10.100.101.1.${ip}
#export ip=((ip++))
#((count++))
#done
#done
export ip=100
for i in 1 2 3 4 5 7 8 9  ; do
	count=1
	while [ ${count} -lt 11 ] ; do
        echo "deploysneaker cnvm@10.100.101.${i} stlalpha/myphusion:stockticker sneaker${ip}.gonkulator.io 10.100.101.${ip}/24"
	((count++))
	((ip++))
	done
done