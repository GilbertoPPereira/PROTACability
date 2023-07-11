# Tutorial on how to use scripts from the manuscript: 
# "Rational prediction of PROTAC compatible ligase-target interfaces"  

To run the scripts, you will need to use:

    Lightdock: https://github.com/lightdock/lightdock/releases/tag/0.9.2
    DockQ: https://github.com/bjornwallner/DockQ 
    VoroMQA: https://github.com/kliment-olechnovic/voronota
    Jwalk: https://github.com/Topf-Lab/XLM-Tools
    ProFit: http://www.bioinf.org.uk/software/profit/ 
    NACCESS: http://www.bioinf.manchester.ac.uk/naccess/
    PyMol: version 2.3.4

### Step 0 - Get the automatic restraints 
> 0.1 - Uses MDAnalysis to produce a file with only residues within X of the ligand and the ligand

> 0.2 - uses naccess to get the dASA (delta SASA) for all residues by comparing the environemnt within the structure and a hypothetial gly-X-gly tripeptide.

> 0.3 - Selects only those residues whose dASA > 25 % (tunable but typically a reference value) and within 6A of ligand.

This step produces a list of restraints for a given protein in a .txt file. We then need to convert it from that file to a .txt file readable by LightDock

### Step 1 - Docking using LightDock
#### Step 1.1 -  Setup the simulation: 

    lightdock3_setup.py ligase.pdb target.pdb -g 200 --noxt --now --verbose_parser --noh -r rest.dat                                
> Ligase.pdb is the ligand-free receptor protein, > Target.pdb is the ligand-free target protein.
                                     
> -g is the number of individual local dockings per swarm (initial positions where local docking is restricted to)
                                     
> -r specifies the restraint file given to bias the docking algorithm
                                    
> -s is the number of local swarms to produce (if not set, the algorihtm chooses a number that appropriately covers the surface of ther receptor)
                                    
Other options are possible but we did not test them (such as ANM for normal mode-based flexibility)
 
 
#### Step 1.2 - Run LightDock: 

    lightdock3.py setup.json 50 -s fastdfire -c 20

> setup.json is the file produced from the setup which initiates the docking (also makes reproducibility a thing)

> 50 is the number of docking cycles (steps) to be carried out

> -c is the number of cores to be used. If you have mpi-ability, it will paralellize everything. If not, it will just submit batches to individual cores
 
                          
### Step 2  - Generating conformations: 

    lgd_generate_conformations.py ../ligase.pdb ../target.pdb gso_50.out 200

> gso_50.out is the file generated per swarm with all possible solutions found for that particular swarm (may include very similar structures)

> 200 is the number of solutions per swarm we want to generate
 
Here, we can use Ant-thony (the LD parallelizer) to make it easy for us.

It goes inside each swarm, and then assigns to each core one of these jobs, meaning that each swarm is treated individually in each core.: 

    echo "cd swarm_${i}; lgd_generate_conformations.py ../4G6M_rec.pdb ../4G6M_lig.pdb  gso_100.out 200 > /dev/null 2> /dev/null;" >> generate_lightdock.list” 
    ant_thony.py -c ${CORES} generate_lightdock.list”
                                    

### Step 3 - Clustering inside each swarm - reduces redundancy in predicted binding poses: 

    lgd_cluster_bsas.py  gso_50.out
                                   
> Here we can use ant_thony again for the same job

    echo "cd swarm_${i}; lgd_cluster_bsas.py gso_100.out > /dev/null 2> /dev/null;" >> cluster_lightdock.list”
    ant_thony.py -c ${CORES} cluster_lightdock.list

### Step 4  - Rank each swarm and then rank the solutions: 
    
    lgd_rank.py $s 50

> $s is the number of swarms simulated

> 50 is the number of steps (remember gso_50.out)

 Until here, we produced a ranking of poses scored by LD (and the fastdfire scoring function). 
 Now, we may want to benchmark our approach. To do So, we use DockQ (it gives both the CAPRI metrics (interface RMSD, ligand RMSD and Fraction of native contacts) as well as an estimation for the quality of the structure based on a continuous function from 0 to 1.
 The criteria are those from CAPRI and/or DockQ
 The comparison is made between each predicted pose (by LD) and the reference structure you benchmark to. The higher the DockQ score, the closer to the reference you are. We run it for all solutions we produced to evaluate the quality of each of them, and then rank them by the LD-Score.

### Steps 5 to 8 – DockQ: 
    /data3/DockQ-master/DockQ.py ${kk}.pdb ref.pdb -useCA -perm1 -perm2 -verbose > DockQ_${kk}.dat  

> kk.pdb is the predicted pose

>ref.pdb is the reference structure

We use only CA to compare the interfaces, keeping solutions if they are AT LEAST acceptable by either CAPRI or DockQ standards.
We say we are accurate at the top10 level (first 10 predicted poses) if within these 10 poses, at  least one is of acceptable quality compared to the reference.
 
 
### Steps 9-10 -  Energy-rescoring using voroMQA (from the Voronota suite)

    voronota-voromqa -i ${kk}.pdb --score-inter-chain > Voro_${kk}.dat

> with kk.pdb being a given predicted structure.
 
Here we are replacing the LD-Score with an energy-based score for the interface produced.
VoroMQA is slow in serial, so we can use ant_thony again, with the same logic!
Here we would re-rank the solutions ordered with LD-score by a ranking produced by Voro-Score.
 
### Steps 11 to 13 – Filtering the re-ranked poses
 
### Step 11 -  First we need to transfer the ligands from the original structures to the predicted poses (align the ligand-bound monomers to the predicted solution using e.g pymol) uses align.py
 
 
 
### Step 12-  Run Jwalk

    jwalk -xl_list perc_${i}.dat -i ${kk}.pdb -ncpus 20 -vox 2

> perc_${i}.dat is the file containing the residues to be used for SASD

Define the anchor atoms for each ligand (this is user defined but we can make it available such that for a given initial structure with a small-molecule ligand bound protein, the user has to specify which atom name in the ligand with a given residue name is to be replaced by CA (to use with Jwalk)

Make a small .dat file specifying the number of the residues containing the anchor atoms and their chain.  Example: “502|B|502|C”
      

 				       
> kk.pdb is a predicted structure pdb

> ncpus is the number of cpus used

> vox is the grid spacing
 
 
 ### Step 13 – Generate the final ranking and compute accuracy.
