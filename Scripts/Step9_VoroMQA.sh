#!/bin/bash

#.. VAR
WORKDIR=$PWD

LIST=$(ls -d */ | cut -d/ -f1)

for i in ${LIST} ; do

cd ${WORKDIR}/${i}/TOP200_PDBs/

echo "Running VoroMQA on Ternary complex ${i}"

#.. clean-up
rm -rf VORO_data.dat

PDBS=$(ls Lightdock*_swarm* | sed 's/.pdb//g')

for kk in ${PDBS} ; do

echo "voronota-voromqa -i ${kk}.pdb --score-inter-chain > Voro_${kk}.dat" >> voro.list

done

/data1/PROTACS/lightdock/bin/ant_thony.py -c 20 voro.list

tot=$(ls Lightdock*_swarm* | sed 's/.pdb//g' | wc -l)

COUNTER=0
for kk in ${PDBS} ; do

cat Voro_${kk}.dat >> VORO_data.dat

let COUNTER++

echo -ne "\r VoroMQA progress: ${COUNTER}/${tot}\r"

done

echo " Finished running VoroMQA on Ternary complex ${i}"

sed -i 's/_/-/g' VORO_data.dat

done


