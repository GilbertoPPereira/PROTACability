#!/bin/bash

WORKDIR=$PWD

LIST=$(ls -d */ | cut -d/ -f1)


## HERE THE PYMOL ALIGN SCRIPT IS TAYLOR MADE PER COMPLEX AND ONE NEEDS TO RENAME THE LIGANDS TO LI1 (LIGASE) AND LI2 (TARGET)

for i in ${LIST} ; do

cd ${WORKDIR}/${i}/TOP200_PDBs/

cp ${WORKDIR}/align.py .
cp ${WORKDIR}/${i}/ligase_lig.pdb .
cp ${WORKDIR}/${i}/target_lig.pdb

rm -rf *_ligs.pdb

PDBs=$(ls Lightdock_*.pdb | sed 's/.pdb//g')

for kk in ${PDBs} ; do

sed "s/aa/${kk}/g" align.py > ${kk}_align.py

pymol ${kk}.pdb ligase_lig.pdb target_lig.pdb -cq ${kk}_align.py

touch ${kk}_ligs.pdb

cat aligned.pdb | grep LI1 >> ${kk}_ligs.pdb 
cat aligned.pdb | grep LI2 >> ${kk}_ligs.pdb

cat ${kk}.pdb > ${kk}_withligs_perc.pdb
cat ${kk}_ligs.pdb >> ${kk}_withligs_perc.pdb

done

done
