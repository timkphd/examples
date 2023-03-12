# TDS examples

The runscript *runall* and the makefiles are designed to build and run two "hello world" examples using the programming environments:

* PrgEnv-cray
* PrgEnv-gnu
* PrgEnv-intel
* IntelMPI





## Main Script

* runall

The overall run script.  You can copy the file runall to you directory and then 

```
sbatch --account=MYACCOUNT runall
```

The script will copy all of the required files to a new directory and build and run the applications.

Or you can copy all of the files to a new directory and edit the file *runall* and change the line:

```
BASE=*.......*
```

to 

```
BASE=`pwd`
```

In either case the script will create a new directory for each run and copy all of the files to the new directroy.

## Rest of the files
* fhostone.f90
* phostone.c

Hybrid MPI/OpenMP hellow world programs.  Run with the options -F -t 10 each will print out a mapping of tasks/threads to nodes and cores and run for 10 seconds.  The programs also report the version of MPI used to build and run.


* makeimpi
* makeprgcray
* makeprggnu
* makeprgintel

Makefiles for the various programming environments.  Each will load the required modules.  This is a bit tricky.  You can't just do a module load and then compile because each command is run in its own shell and the module load is instantly "forgotten" after it completes.  There are a few ways around that issue.  Here we have, for example, the block of code:
		
```
recurse:
	module purge                      ; \
	module load craype-x86-spr        ; \
	module load PrgEnv-cray           ; \
	$(MAKE) -f $(firstword $(MAKEFILE_LIST)) both
```

This is the default target for the make.  It does all of the module loads and then runs the makefile again with the target *both*.  This is the target for the actual build.

* Makefile

The main makefile it just runs make of all of the other make* files.


## Example Output

Here is typical output from the C program built with IntelMPI and the Fortran program build with PrgEnv-cray.  Note the different MPI Version reported by the programs.  The third column gives the node on which a MPI task/thread was run and the last column reports its core.  

```
[tkaiser2@eyas1 5761]$ cat c.impi.out
MPI VERSION Intel(R) MPI Library 2021.8 for Linux* OS

task    thread             node name  first task    # on node  core
0000      0000         x9000c1s2b1n0        0000         0000  0051
0000      0001         x9000c1s2b1n0        0000         0000  0039
0001      0000         x9000c1s2b1n0        0000         0001  0103
0001      0001         x9000c1s2b1n0        0000         0001  0091
0002      0000         x9000c1s2b1n1        0002         0000  0051
0002      0001         x9000c1s2b1n1        0002         0000  0039
0003      0000         x9000c1s2b1n1        0002         0001  0103
0003      0001         x9000c1s2b1n1        0002         0001  0091
total time      5.001
[tkaiser2@eyas1 5761]$


[tkaiser2@eyas1 5761]$ cat f.cray.out
MPI Version:MPI VERSION    : CRAY MPICH version 8.1.20.8 (ANL base 3.4a2)
MPI BUILD INFO : Mon Sep 19 11:26 2022 (git hash 10c7776)

task    thread             node name  first task    # on node  core
0000      0000         x9000c1s2b1n0        0000         0000   000
0000      0001         x9000c1s2b1n0        0000         0000   026
0002      0000         x9000c1s2b1n1        0002         0000   000
0002      0001         x9000c1s2b1n1        0002         0000   026
0003      0000         x9000c1s2b1n1        0002         0001   052
0003      0001         x9000c1s2b1n1        0002         0001   082
0001      0000         x9000c1s2b1n0        0000         0001   052
0001      0001         x9000c1s2b1n0        0000         0001   095
total time       5.00
[tkaiser2@eyas1 5761]$
```

## February 24th

Added sweep.  This script will run the same tests as described above except the number of tasks-per-node
and the setting for OMP_NUM_THREADS is given in the file "cases" in that order.  This can be considered a
stress test.

Added ppong.c, todo.py, runpp.  Thise will run a pingpong test across nodes.  The file todo.py creates
a data file for the ping pong test which restricts the tests to just a few of the MPI tassk.  Without
this file the runtime is N^^2 because it will do exchanges between each set of tasks.

### ppong.c reports


```

S R               Send/Rec MPI tasks
Size              Message size
Bandwidth         Round Trip Bandwidth in bytes/second
Barriers/second   MPI_Barrier calls per second across all tasks

```

Again, to run either of these tests unpack the file runall.tgz in your directory and 


```
   sbatch sweep

```

or

```
   sbatch runpp

```

### RECENT CHANGES

```
I modifide the programs so they can call get_core_number, defined in the file get_core_number.c instead
of sched_getcpu.  I read that the new routine is less likely to cause thread migration.  You can compile
with sched_getcpu by setting USEFAST=no in the makefile.include file.  This is nice for the Fortran 
version because then itcan be compiled without reference to an externally compiled routine.  Also, 
get_core_number might not work on non X86 processors.

For the ping pong test:

You can past the option SR on the command line.  This will 
cause the program to use MPI_Sendrecv instead of explicit
MPI_Send and MPI_Recv.  See runpp for more information.


```

### Final working methods

```
I found there are at least two ways to get good affinity.  This works for all of the compilers I tried.
These are demoed in the sweep script You set the envs:


export KMP_AFFINITY=scatter
export OMP_PROC_BIND=spread

and then either use a mask to assign tasks to sets of nodes or:

export CPUS_TASK="--cpus-per-task=$nthrd"


for il in `seq $nc` ; do
  aline=`cat cases | head -$il | tail -1`
  ntpn=`echo $aline | awk {'print $1'}`
  nthrd=`echo $aline | awk {'print $2'}`
  export OMP_NUM_THREADS=$nthrd
for bindit in NONE MASK ; do
  export KMP_AFFINITY=scatter
  export OMP_PROC_BIND=spread
  export BIND=--cpu-bind=v,${bindit}
  unset CPUS_TASK
  if [ $bindit == MASK ] ; then
	  cores=`expr $ntpn \* $nthrd`
	  MASK=`./maskgenerator.py $cores $ntpn`
	  BIND="--cpu-bind=v,mask_cpu:$MASK"
	  
  fi
  if [ $bindit == NONE ] ; then
	  BIND="--cpu-bind=v"
          export CPUS_TASK="--cpus-per-task=$nthrd"
  fi


```



### Questions? <br>tkaiser2@nrel.gov


