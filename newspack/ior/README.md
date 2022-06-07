# IOR
Builds ior with IntelMPI and OpenMPI


## Usage

Edit the b_openmpi.sh file and change the module load openmpi line to point
to the version you want.  Then just run the two scripts


```
./b_openmpi.sh
./b_intelmpi.sh

```

Your can find where the bin/imp directory is located by running the command.

```
find */install/opt -name ior | grep bin
```


The Intel build actually downloads a new version of IntelMPI but it should run
after a module load of a preinstalled version.

```
# Make sure we intelmpi available
spack install intel-oneapi-mpi
spack load intel-oneapi-mpi
# Here is the install
spack install ior ^intel-oneapi-mpi

```
