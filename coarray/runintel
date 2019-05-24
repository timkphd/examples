#!/bin/bash
#PBS -l nodes=2:ppn=12:core12
#PBS -l walltime=02:00:00
#PBS -N testIO
#PBS -o out.$PBS_JOBID
#PBS -e err.$PBS_JOBID
#PBS -r n
#PBS -V 
#-----------------------------------------------------

cd $PBS_O_WORKDIR


#save a nicely sorted list of nodes
sort -u  $PBS_NODEFILE > mynodes.$PBS_JOBID

echo "running the CAF example"
mpdboot --totalnum=2 --file=mynodes.$PBS_JOBID
#export FOR_COARRAY_NUM_IMAGES=8
./pi < input
export FOR_COARRAY_NUM_IMAGES=24
./pi < input
mpdallexit

