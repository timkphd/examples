# Sample Slurm Batch Scripts

A showcase various programflow techniques by leveraging bash and slurm features.  For MPI examples we assume we will be using Intel MPI but the scripts will work with mpt also.  OpenMP programs are compiled with Intel compilers unless otherwise noted.  

These examples run quickly and most can be run in the debug partition.  The submission line is of the form

```
sbatch –A myaccount --partition=debug --nodes=N script-to-run
```

* [`hostname.sh`](./hostname.sh) - Simple script that just does hostname on all cores.  

* [`multinode-task-per-core.sh`](./multinode-task-per-core.sh) - Example of mapping process execution to each core on an arbitrary amount of nodes.

* [`simple.sh`](./simple.sh) - Runs an MPI program with a set number of cores per node.

* [`hybrid.sh`](./hybrid.sh) - Runs an MPI/OpenMP program with a set number of cores per node.

* [`affinity.sh`](./affinity.sh) - Runs an MPI/OpenMP program with a set number of cores per node, looking at various affinity settings.

* [`newdir.sh`](./newdir.sh) - Create a new directory for each run, save script, environment, and output

* [`fromenv.sh`](./fromenv.sh) - Get input filename from your environment.

* [`mpmd.sh`](./mpmd.sh) - MPI with different programs on various cores - two methods.

* [`mpmd2.sh`](./mpmd2.sh) - MPI with different programs on two nodes with different counts on each node.

* [`multi1.sh`](./multi1.sh) - Multiple applications in a single sbatch submission.

* [`gpucpu.sh`](./gpucpu.sh) - Run a cpu and gpu job in the same script concurrently.

* [`FAN.sh`](./FAN.sh) - A bash script, not a slurm script for submitting a number of jobs with dependencies.  

* [`CHAIN.sh`](./CHAIN.sh) - A bash script, not a slurm script for submitting a number of jobs with dependencies.  A simplified version of FAN, only submits 5 jobs.

* [`old_new_.sh`](./old_new_.sh) - Job submitted by FAN.sh or CHAIN.sh.  Can copy old run data to new directories and rerun.  

* [`uselist.sh`](./uselist.sh) - Array jobs, multiple jobs submitted with a single script.

* [`redirect.sh`](./redirect.sh) - Low level file redirection, allows putting slurm std{err,out} anywhere.

* [`multimax.sh`](./multimax.sh) - Multiple nodes, multiple jobs concurrently with also forcing affinity.


* [`local.sh`](./local.sh) - slrum script showing how to use local \"tmp\" disk.


## Source code, extra scripts, and makefile to use with the above scripts.
###Note:

```
These files are in a subdirectory for organizational purposes.  After checkout, go to this directory and do a make install which will compile and copy files up on level.  Also, you can create a python environment for the examples by sourcing the file jupyter.sh.
 
```

* [`phostone.c`](source/phostone.c) - Glorified hello world in hybrid MPI/OpenMP for some examples.

* [`doarray.py`](source/doarray.py) - Wrapper for uselist.sh, creates inputs and runs uselist.sh.

* [`stf_01.f90`](source/stf_01.f90) - Simple finite difference code to run as an example.

* [`c_ex02.c`](source/c_ex02.c0) - Simple example in C.

* [`f_ex02.f90`](source/f_ex02.f90) - Same as c_ex02.c but in Fortran.


* [`makefile`](source/makefile) - Makefile for examples. Loads module then compiles.

* [`hymain.c`](source/hymain.c) - MPI program that calls a routine that uses GPUS.

* [`hysub.cu`](source/hysub.cu) - Simple routine that accesses GPUs. 

* [`invertc.c`](source/invertc.c) - Matrix inversion program.

* [`report.py`](source/report.py) - A python mpi4py program showing for mapping tasks to cores.

* [`spam.c`](source/spam.c) - Source for a C/python library/module for mapping tasks to cores.

* [`setup.py`](source/setup.py) - Build file for spam.c.

* [`jupyter.sh`](source/jupyter.sh) - Create jupyter/mpi4py/pandas environment with Intel MPI. 

* [`tunnel.sh`](source/tunnel.sh) - Bash function for creating a ssh tunnel to connect to a jupyter notebook.  
 
* [`tymer`](source/tymer) - Glorified wall clock timer.


```
You can get copies of the script without comments by running the command:
for script in `ls *sh` ; do
    out=`echo $script | sed s/.sh$/.slurm/`
    echo $out
    sed  '/:<<++++/,/^++++/d' $script > $out
done
```


