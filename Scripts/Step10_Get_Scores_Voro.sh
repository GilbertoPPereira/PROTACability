#!/bin/bash

WORKDIR=$PWD
LIST=$(ls -d */ | cut -d/ -f1)

for kk in ${LIST} ; do

cd ${WORKDIR}/${kk}/


rm -rf ${WORKDIR}/${kk}_High_VORO.dat
rm -rf ${WORKDIR}/${kk}_Medium_VORO.dat
rm -rf ${WORKDIR}/${kk}_Atleast_Acceptable.dat

cd  ${WORKDIR}/${kk}/TOP200_PDBs/

cat VORO_data.dat | grep -v input | awk '{print $1,$3,$6,$7,$8,$10}' | tr . , | sed 's/,pdb/.pdb/g' > VoroMQA.dat

echo "Name Residues Interface-Atoms Interchain-Contacts Interface-Area Interface-Energy" > tmps

sed 's/.pdb//g' VoroMQA.dat | sed 's/Uniq_//g' | grep -v "Lightdock_Fastdfire" >> tmps

paste Hits_new.dat tmps  > VORO_new.dat

cat VORO_new.dat | sort -nk 18 | grep -v Interface > Sorted_VORO.dat

#.. get tops

cat Sorted_VORO.dat| head -1 > Voro_Top1.dat
cat Sorted_VORO.dat| head -5 > Voro_Top5.dat
cat Sorted_VORO.dat | head -10 > Voro_Top10.dat
cat Sorted_VORO.dat | head -20 > Voro_Top20.dat
cat Sorted_VORO.dat | head -50 > Voro_Top50.dat
cat Sorted_VORO.dat | head -100 > Voro_Top100.dat

echo "${kk} Passes" > ${kk}_data.dat

#.. Acceptable
rm -rf Voro_${kk}_data_high_new.dat
rm -rf Voro_${kk}_data_medium_new.dat
rm -rf Voro_${kk}_data_acceptable_new.dat

for i in Voro_Top1 Voro_Top5 Voro_Top10 Voro_Top20 Voro_Top50 Voro_Top100 ; do

rm -rf passed_${i}_acceptable_new.dat

count=0
while read line ; do
type=$(echo $line | awk '{print $11}')
type2=$(echo $line | awk '{print $12}')
if [ ${type} != "Incorrect" ] || [ ${type2} != "Incorrect" ]  ; then
let count=count+1
fi

done < ${i}.dat 

if (( $(echo "($count != 0)" | bc -l) )) ; then
pass=1
echo "${i} ${pass}" >> Voro_${kk}_data_acceptable_new.dat
echo "${i} ${count}" >> Voro_passed_${i}_acceptable_new.dat
else
echo "${i} 0" >> Voro_${kk}_data_acceptable_new.dat
fi

done

Protocol=$(echo $WORKDIR | sed "s/\//,/g" | awk -F "," '{print $5}')
cp Voro_${kk}_data_acceptable_new.dat Voro_${kk}_Atleast_Acceptable.dat 
cp Voro_${kk}_Atleast_Acceptable.dat ${WORKDIR}/

#..Medium

for i in Voro_Top1 Voro_Top5 Voro_Top10 Voro_Top20 Voro_Top50 Voro_Top100 ; do

rm -rf Voro_passed_${i}_medium_new.dat

count=0
while read line ; do
type=$(echo $line | awk '{print $11}')
type2=$(echo $line | awk '{print $12}')
if [ ${type} == "Medium" ] || [ ${type2} == "Medium" ]  ; then
let count=count+1
fi

done < ${i}.dat 

if (( $(echo "($count != 0)" | bc -l) )) ; then
pass=1
echo "${i} ${pass}" >> Voro_${kk}_data_medium_new.dat
echo "${i} ${count}" >> Voro_passed_${i}_medium_new.dat
else
echo "${i} 0" >> Voro_${kk}_data_medium_new.dat
fi

done

Protocol=$(echo $WORKDIR | sed "s/\//,/g" | awk -F "," '{print $5}')
cp Voro_${kk}_data_medium_new.dat Voro_${kk}_Medium.dat 
cp Voro_${kk}_Medium.dat ${WORKDIR}/


#..High

for i in Voro_Top1 Voro_Top5 Voro_Top10 Voro_Top20 Voro_Top50 Voro_Top100 ; do

rm -rf passed_${i}_high_new.dat

count=0
while read line ; do
type=$(echo $line | awk '{print $11}')
type2=$(echo $line | awk '{print $12}')
if [ ${type} == "High" ] || [ ${type2} == "High" ]  ; then
let count=count+1
fi

done < ${i}.dat 

if (( $(echo "($count != 0)" | bc -l) )) ; then
pass=1
echo "${i} ${pass}" >> Voro_${kk}_data_high_new.dat
echo "${i} ${count}" >> Voro_passed_${i}_high_new.dat
else
echo "${i} 0" >> Voro_${kk}_data_high_new.dat
fi

done

Protocol=$(echo $WORKDIR | sed "s/\//,/g" | awk -F "," '{print $5}')
cp Voro_${kk}_data_high_new.dat Voro_${kk}_High.dat 
cp Voro_${kk}_High.dat ${WORKDIR}/

done


