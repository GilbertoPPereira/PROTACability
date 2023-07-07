#!/bin/bash

WORKDIR=$PWD
LIST=$(ls -d */ | cut -d/ -f1) 

for i in ${LIST} ; do

cd ${WORKDIR}/${i}/

s=`ls -d ./swarm_* | wc -l`;

swarms=$((s-1));	     
lgd_rank_swarm.py $s 50;
lgd_rank.py $s 50;

done

