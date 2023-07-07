#!/bin/bash

WORKDIR=$PWD
LIST=$(ls -d */ | cut -d/ -f1)

for i in ${LIST} ; do

cd ${WORKDIR}/${i}/

echo "lightdock3_setup.py ligase.pdb target.pdb -g 200 --noxt --now --noh -rst rest.dat --verbose_parser" > setup
echo "lightdock3.py setup.json 50 -s fastdfire -c 20" > calculation

bash setup
bash calculation

done

