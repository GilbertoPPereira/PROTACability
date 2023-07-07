#!/bin/bash

#.. VAR
WORKDIR=$PWD
LIST=$(ls -d */ | cut -d/ -f1)

SFs="Fastdfire"

#.. Loop to the folders

for i in ${LIST} ; do
cd ${WORKDIR}/${i}/TOP200_PDBs/
echo "Running DockQ on Ternary complex ${i} with SF ${j}"
#.. clean-up
rm -rf DockQ_*

PDBS=$(ls Lightdock*.pdb | grep -v ligs | grep -v lig | grep -v ref | sed 's/.pdb//g' | grep -v target )

#..Analysis each pdb


for kk in ${PDBS} ; do
echo "/data3/DockQ-master/DockQ.py ${kk}.pdb new_ref.pdb -useCA -perm1 -perm2 -verbose >> DockQ_${kk}_new.dat" >> dockq.list
done

/data1/PROTACS/lightdock/bin/ant_thony.py -c 20 dockq.list


done
