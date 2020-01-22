#!/bin/bash 
#SBATCH --job-name="petsc"
#SBATCH --nodes=2
#SBATCH --export=ALL
#SBATCH --oversubscribe
#SBATCH --time=04:00:00
#SBATCH --account=hpcapps
#SBATCH --exclusive=user

module purge
ml gcc/7.3.0 comp-intel/2018.0.3 intel-mpi/2018.0.3 mkl/2018.3.222

cd $SLURM_SUBMIT_DIR

mkdir $SLURM_JOB_ID
cd $SLURM_JOB_ID
cat $0 > script
printenv > env
startdir=`pwd`
nm="1000"
tasks_per_node="8"
threads="4"
#notes.cholesky: [0]PETSC ERROR: Could not locate a solver package. Perhaps you must ./configure with --download-<package>
#notes.icc:      [0]PETSC ERROR: Could not locate a solver package. Perhaps you must ./configure with --download-<package>
#notes.ilu:      [0]PETSC ERROR: Could not locate a solver package. Perhaps you must ./configure with --download-<package>
#notes.lu:       [0]PETSC ERROR: Could not locate a solver package. Perhaps you must ./configure with --download-<package>
#notes.composite:[0]PETSC ERROR: No composite preconditioners supplied via PCCompositeAddPC() or -pc_composite_pcs
#notes.bddc:     [0]PETSC ERROR: PCBDDC preconditioner requires matrix of type MATIS
#for pc in jacobi bjacobi sor eisenstat icc ilu asm gasm gamg bddc ksp composite lu cholesky none ; do
 for pc in jacobi bjacobi sor eisenstat         asm gasm gamg      ksp                       none ; do
for grid in $nm ; do
    for t1 in $tasks_per_node ; do 
        for t2 in $threads ; do 
          tot=`expr $t1 \* $t2`
          if [ $tot -le 36 ] ; then
               export OMP_NUM_THREADS=$t2
               newdir=`echo $grid/$t1/$t2`
               mkdir -p $newdir
               cd $newdir
               tymer $SLURM_SUBMIT_DIR/$SLURM_JOB_ID/times $newdir $pc start
               srun --ntasks-per-node=$t1 --cpus-per-task=$OMP_NUM_THREADS $SLURM_SUBMIT_DIR/ex16 -log_view -ksp_converged_reason -n $grid -m $grid -pc_type $pc  1> $pc 2> notes.$pc
               tymer $SLURM_SUBMIT_DIR/$SLURM_JOB_ID/times $newdir $pc end
               cd $startdir
          fi
        done
     done
done
done
