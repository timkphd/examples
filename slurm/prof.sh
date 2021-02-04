#!/bin/bash 
#SBATCH --job-name="prof"
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=00:10:00
#SBATCH --out=%J.out
#SBATCH --error=%J.err
#SBATCH --account=hpcapps 
#SBATCH --partition=debug 
#SBATCH --exclude=r104u33,r105u37
#SBATCH --gpus-per-node=2 

export TAG=$SLURM_JOB_ID

ml conda
# needed for nvprof
ml cuda/10.2.89
# next is needed for my version of TF
# this is not a standard module
ml cuda-10.0
ml intel-mpi
# activate my environment to run TF
source activate doimpi
# turn on vtune
source /nopt/nrel/apps/compilers/intel/2020.1.217/vtune_profiler_2020.1.0.607630/vtune-vars.sh

#compile a simple program
icc -g -O3 stc_00.c -o stc_00
mpiicc -g -O3 -parallel-source-info=2 stc_01.c -o stc_01

# run vtune
hostname > P${TAG}
cat /proc/sys/kernel/perf_event_paranoid >> P${TAG}
          vtune -collect hotspots -r vs${TAG} ./stc_00  2>sts${TAG}.log 1> sts${TAG}.out
srun -n 8 vtune -collect hotspots -r vp${TAG} ./stc_01  2>stp${TAG}.log 1> stp${TAG}.out


# run map and perf-report
ml arm
#map --profile --output m${TAG}.map srun -n 8 ./stc_01 > m${TAG}.out 2> m${TAG}.log
map --profile --output m${TAG}.map mpirun -n 8 ./stc_01 > m${TAG}.out 2> m${TAG}.log
map --export=m${TAG}.json m${TAG}.map > m${TAG}.log 2>&1

#perf-report --output p${TAG} srun -n 8 ./stc_01
perf-report --output p${TAG} mpiexec -n 8 ./stc_01 > p${TAG}.out

# To see the profile do from a login node...
# map *map

# gprof is useless for this program but this is how you would run it
# icc -g -O0 stc_00.c -pg -o stc_00.pg 
# ./stc_00.pg
# gprof -a ./stc_00


# run GPU profiling if we are running on a GPU node
hostname              > ${TAG}.gpus
echo -n "gpu count " >> ${TAG}.gpus
gpucount             >> ${TAG}.gpus
if [ $? == 0 ] ;then 
  echo " " >> ${TAG}.gpus 
  echo "running on gpu" >> ${TAG}.gpus
else 
  echo " " >> ${TAG}.gpus 
  echo "no gpus were found" >> ${TAG}.gpus
  exit
fi

# TF example
#head -20 tfexamp.py 

# run nvprof
nvprof ./tfexamp.py 2> nv${TAG}.log > nv${TAG}.out

