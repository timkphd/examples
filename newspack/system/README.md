# Build HPC software stacks
Theses are designed to create software stacks for doing HPC and for building additional software. *git.sh* only installs wget and git but the other two install:


### newstage.sh
1. spack install gcc
1. spack install gcc
1. spack install nvhpc +blas +mpi +lapack
1. spack install intel-oneapi-compilers
1. spack install intel-oneapi-mpi intel-oneapi-ccl  intel-oneapi-dal intel-oneapi-dnn intel-oneapi-ipp intel-oneapi-ippcp intel-oneapi-mkl intel-oneapi-tbb intel-oneapi-vpl
1. spack install git
1. spack install gmake
1. spack install cmake
1. spack install julia
1. spack install python@3.10.2 +tkinter
1. spack install ucx +verbs  +rc +ud +mlx5_dv
1. spack install --reuse openmpi@4.1.3 fabrics=ucx schedulers=slurm pmi=true static=false +cuda +java
1. spack install libjpeg
1. spack install libpng
1. spack install r

###stage0.sh
1. spack install gcc
1. spack install gcc
1. spack install nvhpc@22.2 +blas +mpi +lapack
1. spack install fftw -mpi
1. spack install intel-oneapi-compilers
1. spack install intel-oneapi-mpi intel-oneapi-ccl  intel-oneapi-dal intel-oneapi-dnn intel-oneapi-ipp intel-oneapi-ippcp intel-oneapi-mkl intel-oneapi-tbb intel-oneapi-vpl
1. spack install git
1. spack install gmake
1. spack install cmake
1. spack install julia
1. spack install python@3.10.2 +tkinter
1. spack install r


Note that gcc is listed twice in both cases.  This is intentional.  Gcc is built then the new version of gcc is used to build the rest of the stack, including a new copy of gcc.  This is done in a hyeratcial fashion as described in ../staged/README.md.

We use a user defined package.yaml file to install julia.  This is done to build against gcc instead of llvm/clang and to prevent the requirement of installing many other dependecies.  

After the build of julia and python addition packages are also install for these apps.  

The install of nvhpc will also install its own (older) version of openmpi.  

The two scripts are very similar but use different methods to point to the preinstalled environement, either module load or export PATH.  In either case you will most likely need to adjust these to get the scripts to work properly.  You will also need to edit the files to point to your desired install directory.  

```
export MYDIR=/nopt/nrel/apps/220421a
```

## Usage
Edit the files as described above then "sbatch" the files.  You will need to set your account and the parition on the sbatch line.

```
sbatch --account=myaccount --partition=std newstage.sh

```



The scripts also create two files dirsettings and dospack.func.  Sourcing these two files and then running the function dospack will allow you to add applications to the spack instances.  For example:

```
source dirsettings
source dospack.func
dospack

spack install wget
```

