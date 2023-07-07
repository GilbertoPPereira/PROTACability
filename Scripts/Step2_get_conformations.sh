#!/bin/bash

WORKDIR=$PWD
LIST=$(ls -d */ | cut -d/ -f1)

#..get conformations

for i in ${LIST} ; do

cd ${WORKDIR}/${i}/

rm -rf generate_lightdock.list

s=`ls -d ./swarm_* | wc -l`;

swarms=$((s-1));

for k in $(seq 0 $swarms); do

echo " cd ${WORKDIR}/${i}/swarm_${k}/; lgd_generate_conformations.py ../ligase.pdb ../target.pdb gso_50.out 200" >> generate_lightdock.list

done

/data1/PROTACS/lightdock/bin/ant_thony.py -c 20 generate_lightdock.list

done
