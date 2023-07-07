#!/bin/bash

WORKDIR=$PWD
LIST=$(ls -d */ | cut -d/ -f1)

for i in ${LIST} ; do   

cd ${WORKDIR}/${i}/
s=`ls -d ./swarm_* | wc -l`; 
swarms=$((s-1)); 

for k in $(seq 0 $swarms); do  

echo "cd ${WORKDIR}/${i}/swarm_${k}/; lgd_cluster_bsas.py  gso_50.out" >> cluster.list

done

/data1/PROTACS/lightdock/bin/ant_thony.py -c 20 cluster.list

done

