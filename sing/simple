#!/bin/bash 
#SBATCH --job-name="hybrid"
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=02:00:00
#SBATCH --partition=standard
#SBATCH --mem=0


cat $0 >       $SLURM_JOB_ID.script
printenv >     $SLURM_JOB_ID.env

module use /nopt/nrel/apps/timstests/042723_a/tcl/linux-rhel8-icelake
module load apptainer-1.1.8-gcc-12.1.0-tbna3nr

module list >  $SLURM_JOB_ID.mods  2>&1

which apptainer >> $SLURM_JOB_ID.mods

#FI_PROVIDER set for mpich_ch4 to work
export FI_PROVIDER=tcp
export MPIR_CVAR_DEBUG_SUMMARY=1
export OMP_NUM_THREADS=1

                      apptainer  exec --bind /var/spool/slurmd --bind /usr/bin --bind /nopt/slurm/current/lib --bind /nopt/xalt/xalt/lib64 --bind /nopt/slurm/current/bin  openmpi.sif    ompi_info --all > hello.openmpi
srun -n4 --mpi=pmix   apptainer  exec --bind /var/spool/slurmd --bind /usr/bin --bind /nopt/slurm/current/lib --bind /nopt/xalt/xalt/lib64 --bind /nopt/slurm/current/bin  openmpi.sif    /opt/examples/affinity/tds/phostone -F >> hello.openmpi
srun -n4 --mpi=pmi2   apptainer  exec --bind /var/spool/slurmd --bind /usr/bin --bind /nopt/slurm/current/lib --bind /nopt/xalt/xalt/lib64 --bind /nopt/slurm/current/bin  mpich_ch4.sif  /opt/examples/affinity/tds/phostone -F >  hello.mpich_ch4 
srun -n4 --mpi=pmi2   apptainer  exec --bind /var/spool/slurmd --bind /usr/bin --bind /nopt/slurm/current/lib --bind /nopt/xalt/xalt/lib64 --bind /nopt/slurm/current/bin  mpich_ch4b.sif /opt/examples/affinity/tds/phostone -F >  hello.mpich_ch4b 
srun -n4 --mpi=pmi2   apptainer  exec --bind /var/spool/slurmd --bind /usr/bin --bind /nopt/slurm/current/lib --bind /nopt/xalt/xalt/lib64 --bind /nopt/slurm/current/bin  mpich_ch3.sif  /opt/examples/affinity/tds/phostone -F >  hello.mpich_ch3 

unset MPIR_CVAR_DEBUG_SUMMARY
srun -n4 --mpi=pmix   apptainer  exec --bind /var/spool/slurmd --bind /usr/bin --bind /nopt/slurm/current/lib --bind /nopt/xalt/xalt/lib64 --bind /nopt/slurm/current/bin  openmpi.sif    /opt/examples/affinity/tds/ppong  > ppong.openmpi
srun -n4 --mpi=pmi2   apptainer  exec --bind /var/spool/slurmd --bind /usr/bin --bind /nopt/slurm/current/lib --bind /nopt/xalt/xalt/lib64 --bind /nopt/slurm/current/bin  mpich_ch4.sif  /opt/examples/affinity/tds/ppong  > ppong.mpich_ch4
srun -n4 --mpi=pmi2   apptainer  exec --bind /var/spool/slurmd --bind /usr/bin --bind /nopt/slurm/current/lib --bind /nopt/xalt/xalt/lib64 --bind /nopt/slurm/current/bin  mpich_ch4b.sif /opt/examples/affinity/tds/ppong  > ppong.mpich_ch4b
#this is very slow
srun -n4 --mpi=pmi2   apptainer  exec --bind /var/spool/slurmd --bind /usr/bin --bind /nopt/slurm/current/lib --bind /nopt/xalt/xalt/lib64 --bind /nopt/slurm/current/bin  mpich_ch3.sif  /opt/examples/affinity/tds/ppong  > ppong.mpich_ch3


:<< OPENMPI_X
Bootstrap: docker
from: ubuntu:latest

%environment
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cray/pe/lib64
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cray/libfabric/1.15.2.0/lib64
    # Point to OPENMPI binaries, libraries man pages
    export OPENMPI_DIR=/opt/openmpi
    export PATH="$OPENMPI_DIR/bin:$PATH"
    export LD_LIBRARY_PATH="$OPENMPI_DIR/lib:$LD_LIBRARY_PATH"
    export MANPATH=$OPENMPI_DIR/share/man:$MANPATH
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cray/pe/lib64




%post
    echo "Installing required packages..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update && apt-get install -y wget git bash gcc gfortran g++ make python3
    apt install -y git
    apt install -y curl
    curl https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.5.tar.gz --output openmpi-4.1.5.tar.gz
    mkdir -p /opt/openmpi/src
    tar -xzf openmpi-4.1.5.tar.gz -C /opt/openmpi/src


    echo "Installing OPENMPI..."
     # Compile and install
    cd /opt/openmpi/src/* && ./configure --prefix=/opt/openmpi --disable-mpi-fortran --enable-orterun-prefix-by-default && make install

    # Set env variables so we can compile our application
    export PATH=/opt/openmpi/bin:$PATH
    export LD_LIBRARY_PATH=/opt/openmpi/lib:$LD_LIBRARY_PATH

    echo "Compiling the MPI application..."
    echo "Compiling the MPI application..."
    cd /opt && git clone https://github.com/timkphd/examples.git
    cd /opt/examples/affinity/tds && mpicc -fopenmp phostone.c -o phostone

OPENMPI_X

:<< MPICH_X
Bootstrap: docker
from: ubuntu:latest
%environment
    # Point to MPICH binaries, libraries man pages
    export MPICH_VERSION=4.1.2
    export MPICH_DIR=/opt/mpich
    export PATH="$MPICH_DIR/bin:$PATH"
    export LD_LIBRARY_PATH="$MPICH_DIR/lib:$LD_LIBRARY_PATH"
    export MANPATH=$MPICH_DIR/share/man:$MANPATH



%post
    echo "Installing required packages..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update && apt-get install -y wget git bash gcc gfortran g++ make python3
    apt install -y git
#    apt install -y mpich


    # Information about the version of MPICH to use
    export MPICH_VERSION=4.1.2
    export MPICH_URL="http://www.mpich.org/static/downloads/$MPICH_VERSION/mpich-$MPICH_VERSION.tar.gz"

    echo "Installing MPICH..."
    mkdir -p /opt/build
    mkdir -p /opt
    # Download
    cd /opt/build && wget -O mpich-$MPICH_VERSION.tar.gz $MPICH_URL && tar xzf mpich-$MPICH_VERSION.tar.gz
    # Compile and install
    cd /opt/build/mpich-$MPICH_VERSION && ./configure --prefix=/opt/mpich --with-device=ch3:nemesis && make install
    #cd /opt/build/mpich-$MPICH_VERSION && ./configure --prefix=/opt/mpich --with-ch4-shmmods=auto --with-device=ch4 && make install
    #cd /opt/build/mpich-$MPICH_VERSION && ./configure --prefix=/opt/mpich  --with-device=ch4 && make install

    # Set env variables so we can compile our application
    export PATH=/opt/mpich/bin:$PATH
    export LD_LIBRARY_PATH=/opt/mpich/lib:$LD_LIBRARY_PATH

    echo "Compiling the MPI application..."
    cd /opt && git clone https://github.com/timkphd/examples.git
    cd /opt/examples/affinity/tds && mpicc -fopenmp phostone.c -o phostone

MPICH_X

