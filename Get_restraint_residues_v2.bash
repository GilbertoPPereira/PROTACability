#!/bin/bash

#alias nacess=/data1/PROTACS/MONOMERS/Ligases/CRBN/TEST/naccess2.1.1/naccess

rm -rf tmp

##### Ligase restraints
python3<<EOF
import MDAnalysis as md
aa = md.Universe('ligase_lig.pdb')
bb = aa.select_atoms('protein and around 4.0 resname LIG')
with open('filename.txt', 'w+') as topout:
	for a,b in zip(bb.residues.resnames, bb.residues.resids):
		topout.write(f'{a},{b}')
cc = aa.select_atoms('resname LIG')
bb.residues.atoms.write('residues.pdb')
cc.atoms.write('lig.pdb')
EOF

grep -v "END" residues.pdb  | grep -v "TITLE" | grep -v "CRYST" | grep -v "REMARK" | grep -v "CONECT" | grep -v "HEADER" > resids.pdb
grep -v "HEADER" lig.pdb  | grep -v "TITLE" | grep -v "CRYST" | grep -v "REMARK" | grep -v "CONECT" > tmp.pdb

cat tmp.pdb >> resids.pdb

echo "
; '???' or '*' matches any residue name
; VanderWaals radii from:
; R.S. Rowland and Robin Taylor, J. Phys. Chem. 1996, 100, 7384-7391
; "P" is from [A. Bondi, J. Phys. Chem. 68 (1964) 441-451] because missing from R.S. Rowland's work.
???  H     0.109
???  C     0.175
???  N     0.161
???  O     0.156
???  F     0.144
???  P     0.18
???  S     0.179
???  Cl    0.174
???  Br    0.185
???  I     0.200
" > vdwradii.dat


/data1/PROTACS/MONOMERS/Ligases/CRBN/TEST/naccess2.1.1/naccess resids.pdb

cat resids.rsa | grep -v REM | grep -v END | grep -v CHAIN | grep -v TOTAL > results_nacces.dat
cp results_nacces.dat results_nacces_ligase.dat
cp resids.pdb ligase_resids.pdb


cut=25

while read line ; do
id=$( echo $line | awk '{print $4}')
name=$( echo $line | awk '{print $2}')
rel=$(echo $line | awk '{print $6}')
if (( $(bc <<< "$rel > $cut" ) )) ; then
echo $id $name $rel
fi
done < results_nacces.dat  > Res_Rest.dat

# Ratio < 25%, SASA indicated buried according to the relative Solvent Accessible Area

cp Res_Rest.dat Lig_rest.dat


######################################. target

python3<<EOF
import MDAnalysis as md
aa = md.Universe('target_lig.pdb')
bb = aa.select_atoms('protein and around 4.0 resname LIG')
with open('filename.txt', 'w+') as topout:
	for a,b in zip(bb.residues.resnames, bb.residues.resids):
		topout.write(f'{a},{b}')
cc = aa.select_atoms('resname LIG')
bb.residues.atoms.write('residues.pdb')
cc.atoms.write('lig.pdb')
EOF

grep -v "END" residues.pdb  | grep -v "TITLE" | grep -v "CRYST" | grep -v "REMARK" | grep -v "CONECT" | grep -v "HEADER" > resids.pdb
grep -v "HEADER" lig.pdb  | grep -v "TITLE" | grep -v "CRYST" | grep -v "REMARK" | grep -v "CONECT" > tmp.pdb

cat tmp.pdb >> resids.pdb

echo "
; '???' or '*' matches any residue name
; VanderWaals radii from:
; R.S. Rowland and Robin Taylor, J. Phys. Chem. 1996, 100, 7384-7391
; "P" is from [A. Bondi, J. Phys. Chem. 68 (1964) 441-451] because missing from R.S. Rowland's work.
???  H     0.109
???  C     0.175
???  N     0.161
???  O     0.156
???  F     0.144
???  P     0.18
???  S     0.179
???  Cl    0.174
???  Br    0.185
???  I     0.200
" > vdwradii.dat


/data1/PROTACS/MONOMERS/Ligases/CRBN/TEST/naccess2.1.1/naccess resids.pdb

cat resids.rsa | grep -v REM | grep -v END | grep -v CHAIN | grep -v TOTAL > results_nacces.dat
cp results_nacces.dat results_nacces_target.dat
cp resids.pdb target_resids.pdb


cut=25

while read line ; do
id=$( echo $line | awk '{print $4}')
name=$( echo $line | awk '{print $2}')
rel=$(echo $line | awk '{print $6}')
if (( $(bc <<< "$rel > $cut" ) )) ; then
echo $id $name $rel
fi
done < results_nacces.dat  > Res_Rest.dat

# Ratio < 25%, SASA indicated buried according to the relative Solvent Accessible Area

cp Res_Rest.dat TargetRes_Rest.dat


#### write rest


chain=$(tail -2 ligase.pdb  | awk '{print $5}' | head -1)

cat Lig_rest.dat | awk -v chain=$chain '{print "Rchain",$2,$1}' | sed 's/ /./g' | sed "s/Rchain/R ${chain}/g" > rest.dat

chain2=$(tail -2 target.pdb  | awk '{print $5}' | head -1)

cat TargetRes_Rest.dat | awk -v chain=$chain2 '{print "Lchain",$2,$1}' | sed 's/ /./g' | sed "s/Lchain/L ${chain2}/g" >> rest.dat
