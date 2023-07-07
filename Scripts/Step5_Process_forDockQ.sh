#!/bin/bash

WORKDIR=$PWD
LIST=$(ls -d */ | cut -d/ -f1)
# Get top200 poses. Maybe should be adapted.

for i in ${LIST} ; do 
cd ${WORKDIR}/${i}/

echo "#1 - Copying PDBs"

rm -rf TOP200_${i}_${k}.dat TOP200_PDBs/ temp

if [ -f rank_by_scoring.list ] ; then
echo $i
fi

echo "--- NEXT SYSTEM: ${i} ---"
mkdir TOP200_PDBs 

echo "$i" > TOP200_${i}.dat 
head -n 201 rank_by_scoring.list >> TOP200_${i}.dat  
echo "Swarm Glowworm Name LD_Score" > Master
cat TOP200_${i}.dat | awk '{print $1,$2,$16,$18}' | tail -n +3 >> Master

					 	
while read line ; do
var=$(echo "$WORKDIR" | cut -d/ -f5)
swarm=$(echo $line | awk '{print $1}')
id=$(echo $line | awk '{print $2}')
echo "cp ${WORKDIR}/${i}/swarm_${swarm}/lightdock_${id}.pdb ${WORKDIR}/${i}/TOP200_PDBs/Lightdock_${var}_swarm_${swarm}_${id}.pdb"
echo "${WORKDIR}/${i}/${j}/TOP200_PDBs/Lightdock_${var}_swarm_${swarm}_${id}_${j}.pdb" >> temp
done < TOP200_${i}.dat | tail -n +2 > aa

cat temp | grep -v Glowworm | grep -v "__" > tmp
echo "PDB" > tmp2
cat tmp >> tmp2

grep -v Glowworm aa > tocopy.bash

bash tocopy.bash	

cp new_ref.pdb ${WORKDIR}/${i}/TOP200_PDBs/	

done      
