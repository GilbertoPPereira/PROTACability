#!/bin/bash

### please do these steps
#0 align the structures of the monomers on the predicted pose, insert the ligands using pymol
#1 select anchor atoms. we selected the Carbon closest to the linker start on either side
#2 replace that carbon atom type by CA

# we used these commands
######
##STRUT=$(ls Uniq_Lightdock_Realistic_Docking_*_withligs.pdb | sed 's/.pdb//g')
##for kk in ${STRUT} ; do sed "s/C29 LI1 B 502/CA  LI1 B 502/g" ${kk}.pdb > ${kk}_1.pdb ; sed "s/C14 LI2 C 501/CA  LI2 C 501/g" ${kk}_1.pdb > ${kk}_perc.pdb; done
## HERE THE SED REPLACES ONE ANCHOR ATOM ON EITHER SIDE. MODIFY TO MAKE IT CLEANER
######

### ACTUAL CODE

WORKDIR=$PWD
LIST=$(ls -d */ | cut -d/ -f1)

#.. Run JWALK
for i in ${LIST} ; do

echo "RUNNING PERCOLATION FOR ${i}"

cd ${WORKDIR}/${i}/TOP200_PDBs/
cp ../perc_${i}.dat

rm -rf Jwalk*
rm -rf perc.list

cp ${WORKDIR}/perc_${i}.dat ${WORKDIR}/${i}/TOP200_PDBs/

STRUT=$(ls Lightdock*_withligs_perc.pdb | sed 's/.pdb//g')

for kk in ${STRUT} ; do

sed -i 's/HETATM/ATOM  /g' ${kk}.pdb

jwalk -xl_list perc_${i}.dat -i ${kk}.pdb -ncpus 20 -vox 2

mv Jwalk_results Jwalk_results_${kk} 

done

done

#.. PROCESS

for i in ${LIST} ; do

echo "PROCESSING PERCOLATION FOR ${i}"

cd ${WORKDIR}/${i}/TOP200_PDBs/

rm -rf Perc.dat

STRUT=$(ls Lightdock*_withligs_perc.pdb | sed 's/.pdb//g')

echo "Name SASD" > Perc.dat

for kk in ${STRUT} ; do

cd ${WORKDIR}/${i}/TOP200_PDBs/Jwalk_results_${kk}/

SASD=$(cat ${kk}_crosslink_list.txt | tail -1  |  awk '{print $5}')

echo $kk $SASD >> ${WORKDIR}/${i}/TOP200_PDBs/Perc.dat

done

done
