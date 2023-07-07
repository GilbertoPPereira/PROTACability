#!/bin/bash

WORKDIR=$PWD
LIST=$(ls -d */ | cut -d/ -f1)
for kk in ${LIST} ; do

cd ${WORKDIR}/${kk}/

rm -rf temp
rm -rf temp2
rm -rf Scores_LD.dat
rm -rf aa

while read line ; do
var=$(echo "$WORKDIR" | cut -d/ -f5)
swarm=$(echo $line | awk '{print $1}')
id=$(echo $line | awk '{print $2}')
echo "Lightdock_${var}_swarm_${swarm}_${id}.pdb" >> temp
done < TOP200_${kk}.dat 

sed 's/swarm_Swarm_Glowworm_//'  temp | tail -n +2  > temp2

paste Master temp2 > Scores_LD.dat

cp Scores_LD.dat ${WORKDIR}/${kk}/TOP200_PDBs/

cd  ${WORKDIR}/${kk}/TOP200_PDBs/

echo "Swarm Glowworm Name LD_Score Protocol" > tmp

sed 's/.pdb//g' Scores_LD.dat | sort | head -n -1 >> tmp

paste tmp DockQ_${kk}_new.dat > Hits_new.dat

cat Hits_new.dat | tr . , | sort -rn  -k4 > Sorted_Score_Hits.dat
sed -i "s/,/./g" Sorted_Score_Hits.dat

#.. get tops

cat Sorted_Score_Hits.dat | head -1 > Top1.dat
cat Sorted_Score_Hits.dat | head -5 > Top5.dat
cat Sorted_Score_Hits.dat | head -10 > Top10.dat
cat Sorted_Score_Hits.dat | head -20 > Top20.dat
cat Sorted_Score_Hits.dat | head -50 > Top50.dat
cat Sorted_Score_Hits.dat | head -100 > Top100.dat

echo "${kk} Passes" > ${kk}_data_new.dat

#.. Acceptable
rm -rf ${kk}_data_high_new.dat
rm -rf ${kk}_data_medium_new.dat
rm -rf ${kk}_data_acceptable_new.dat

for i in Top1 Top5 Top10 Top20 Top50 Top100 ; do

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
echo "${i} ${pass}" >> ${kk}_data_acceptable_new.dat
echo "${i} ${count}" >> passed_${i}_acceptable_new.dat
else
echo "${i} 0" >> ${kk}_data_acceptable_new.dat
fi

done

Protocol=$(echo $WORKDIR | sed "s/\//,/g" | awk -F "," '{print $5}')
cp ${kk}_data_acceptable_new.dat ${kk}_Atleast_Acceptable.dat 
cp ${kk}_Atleast_Acceptable.dat ${WORKDIR}/

#..Medium

for i in Top1 Top5 Top10 Top20 Top50 Top100 ; do

rm -rf passed_${i}_medium_new.dat

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
echo "${i} ${pass}" >> ${kk}_data_medium_new.dat
echo "${i} ${count}" >> passed_${i}_medium_new.dat
else
echo "${i} 0" >> ${kk}_data_medium_new.dat
fi

done

Protocol=$(echo $WORKDIR | sed "s/\//,/g" | awk -F "," '{print $5}')
cp ${kk}_data_medium_new.dat ${kk}_Medium.dat 
cp ${kk}_Medium.dat ${WORKDIR}/


#..High

for i in Top1 Top5 Top10 Top20 Top50 Top100 ; do

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
echo "${i} ${pass}" >> ${kk}_data_high_new.dat
echo "${i} ${count}" >> passed_${i}_high_new.dat
else
echo "${i} 0" >> ${kk}_data_high.dat
fi

done

Protocol=$(echo $WORKDIR | sed "s/\//,/g" | awk -F "," '{print $5}')
cp ${kk}_data_high.dat ${kk}_High.dat 
cp ${kk}_High.dat ${WORKDIR}/

done


