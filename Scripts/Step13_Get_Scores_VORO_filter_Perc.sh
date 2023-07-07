#!/bin/bash

WORKDIR=$PWD
LIST=$(ls -d */ | cut -d/ -f1)

#..set intervals from ligases

MIN=3
MAX=13.7

for kk in ${LIST} ; do

echo $kk

cd ${WORKDIR}/${kk}/


rm -rf ${WORKDIR}/${kk}_High_VORO_filter_Perc.dat
rm -rf ${WORKDIR}/${kk}_Medium_VORO_filter_Perc.dat
rm -rf ${WORKDIR}/${kk}_Atleast_Acceptable_filter_Perc.dat

cd ${WORKDIR}/${kk}/TOP200_PDBs/

rm -rf New_Perc.dat New_Perc_noFails_use.dat New_Perc_passed.dat

paste VORO_new.dat Perc.dat > New_Perc.dat

sed 's/\,/./g' New_Perc.dat > New_Perc_noFails_use.dat

while read line ; do
val=$(echo $line | awk '{print $20}')
if (( $(echo "($val > $MIN && $val < $MAX)" | bc -l) )) ; then 
echo $line >> New_Perc_passed.dat
fi
done < New_Perc_noFails_use.dat

cat New_Perc_passed.dat | tr . , | sort -nk 18 > Sorted_VORO_Perc_noFails_passed.dat

#.. get tops

cat Sorted_VORO_Perc_noFails_passed.dat | head -1 > Filter_Voro_Top1_Perc.dat
cat Sorted_VORO_Perc_noFails_passed.dat | head -5 > Filter_Voro_Top5_Perc.dat
cat Sorted_VORO_Perc_noFails_passed.dat | head -10 > Filter_Voro_Top10_Perc.dat
cat Sorted_VORO_Perc_noFails_passed.dat | head -20 > Filter_Voro_Top20_Perc.dat
cat Sorted_VORO_Perc_noFails_passed.dat | head -50 > Filter_Voro_Top50_Perc.dat
cat Sorted_VORO_Perc_noFails_passed.dat | head -100 > Filter_Voro_Top100_Perc.dat

echo "${kk} Passes" > ${kk}_data_Perc.dat

#.. Acceptable
rm -rf Voro_${kk}_data_high_Perc_new.dat
rm -rf Voro_${kk}_data_medium_Perc_new.dat
rm -rf Voro_${kk}_data_acceptable_Perc_new.dat

for i in Filter_Voro_Top1 Filter_Voro_Top5 Filter_Voro_Top10 Filter_Voro_Top20 Filter_Voro_Top50 Filter_Voro_Top100 ; do

rm -rf passed_${i}_acceptable_Perc_new.dat

count=0
while read line ; do
type=$(echo $line | awk '{print $11}')
type2=$(echo $line | awk '{print $12}')
if [ ${type} != "Incorrect" ] || [ ${type2} != "Incorrect" ]  ; then
let count=count+1
fi

done < ${i}_Perc.dat 

if (( $(echo "($count != 0)" | bc -l) )) ; then
pass=1
echo "${i} ${pass}" >> Voro_${kk}_data_acceptable_Perc_new.dat
echo "${i} ${count}" >> Voro_passed_${i}_acceptable_Perc_new.dat
else
echo "${i} 0" >> Voro_${kk}_data_acceptable_Perc_new.dat
fi

done

Protocol=$(echo $WORKDIR | sed "s/\//,/g" | awk -F "," '{print $5}')
cp Voro_${kk}_data_acceptable_Perc_new.dat Voro_${kk}_Atleast_Acceptable_filter_Perc_new.dat 
cp Voro_${kk}_Atleast_Acceptable_filter_Perc_new.dat ${WORKDIR}/

#..Medium

for i in Filter_Voro_Top1 Filter_Voro_Top5 Filter_Voro_Top10 Filter_Voro_Top20 Filter_Voro_Top50 Filter_Voro_Top100 ; do

rm -rf Voro_passed_${i}_medium_Perc_new.dat

count=0
while read line ; do
type=$(echo $line | awk '{print $11}')
type2=$(echo $line | awk '{print $12}')
if [ ${type} == "Medium" ] || [ ${type2} == "Medium" ]  ; then
let count=count+1
fi

done < ${i}_Perc.dat 

if (( $(echo "($count != 0)" | bc -l) )) ; then
pass=1
echo "${i} ${pass}" >> Voro_${kk}_data_medium_Perc_new.dat
echo "${i} ${count}" >> Voro_passed_${i}_medium_Perc_new.dat
else
echo "${i} 0" >> Voro_${kk}_data_medium_Perc_new.dat
fi

done

Protocol=$(echo $WORKDIR | sed "s/\//,/g" | awk -F "," '{print $5}')
cp Voro_${kk}_data_medium_Perc_new.dat Voro_${kk}_Medium_filter_Perc_new.dat 
cp Voro_${kk}_Medium_filter_Perc_new.dat ${WORKDIR}/


#..High

for i in Filter_Voro_Top1 Filter_Voro_Top5 Filter_Voro_Top10 Filter_Voro_Top20 Filter_Voro_Top50 Filter_Voro_Top100 ; do

rm -rf passed_${i}_high_Perc_new.dat

count=0
while read line ; do
type=$(echo $line | awk '{print $11}')
type2=$(echo $line | awk '{print $12}')
if [ ${type} == "High" ] || [ ${type2} == "High" ]  ; then
let count=count+1
fi

done < ${i}_Perc.dat 

if (( $(echo "($count != 0)" | bc -l) )) ; then
pass=1
echo "${i} ${pass}" >> Voro_${kk}_data_high_Perc_new.dat
echo "${i} ${count}" >> Voro_passed_${i}_high_Perc_new.dat
else
echo "${i} 0" >> Voro_${kk}_data_high_Perc_new.dat
fi

done

Protocol=$(echo $WORKDIR | sed "s/\//,/g" | awk -F "," '{print $5}')
cp Voro_${kk}_data_high_Perc_new.dat Voro_${kk}_High_filter_Perc_new.dat 
cp Voro_${kk}_High_filter_Perc_new.dat ${WORKDIR}/

done


