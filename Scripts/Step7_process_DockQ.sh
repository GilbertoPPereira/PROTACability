#!/bin/bash

WORKDIR=$PWD
LIST=$(ls -d */ | cut -d/ -f1)

#.. Loop to the folders

for i in ${LIST} ; do
cd ${WORKDIR}/${i}/TOP200_PDBs/
echo "Processing DockQ on Ternary complex ${i}"

PDBS=$(ls Lightdock*.pdb | grep -v ligs | grep -v lig | grep -v ref | sed 's/.pdb//g' | grep -v target )
echo "Name Fnat int-RMSD Ligand-RMSD DockQ-Score CAPRI DockQ_class" > DockQ_${i}_new.dat

COUNTER=0
for kk in ${PDBS} ; do
		
#..extract data to summary file
name=$(echo ${kk} | sed 's/Uniq_//g' | sed 's/_Scoring//g')
Fnat=$(cat DockQ_${kk}_new.dat | awk '{print $2}' | tail -n 9 | head -1)
iRMS=$(cat DockQ_${kk}_new.dat | awk '{print $2}' | tail -n 7 | head -1 )
LRMSD=$(cat DockQ_${kk}_new.dat | awk '{print $2}' | tail -n 6 | head -1 )
DockQ=$(cat DockQ_${kk}_new.dat | awk '{print $2}' | tail -1 )
CAPRI=$(cat DockQ_${kk}_new.dat | awk '{print $2}' | tail -n 5 | head -1 )
DockQ_class=$(cat DockQ_${kk}_new.dat | awk '{print $2}' | tail -n 2 | head -1 )


echo "${name} ${Fnat} ${iRMS} ${LRMSD} ${DockQ} ${CAPRI} ${DockQ_class}" >> DockQ_${i}_new.dat
let COUNTER++
echo -ne "\r DockQ progress: ${COUNTER}/200\r"
done
echo " Finished running DockQ on Ternary complex ${i}"
done
