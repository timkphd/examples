#!/bin/bash
#SBATCH --job-name="hybrid"
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=08:00:00
##SBATCH --partition=sm
##SBATCH --output=system_build
##SBATCH --error=system_build

module purge
# point to our gcc install
module use /nopt/nrel/apps/220525b/level00/modules/lmod/linux-centos7-x86_64/gcc/12.1.0/
module load gcc
module load python
module load git

stamp () { date +"%y%m%d%H%M%S"; }
export WORKDIR=`stamp`
mkdir $WORKDIR
cd $WORKDIR
export WORKDIR=`pwd`

export MYDIR=/nopt/nrel/apps/220525b/level01
rm -rf $MYDIR
mkdir -p $MYDIR

cat $0 > $WORKDIR/script
cat $0 > $MYDIR/script

export TMPDIR=$MYDIR/tmp
mkdir -p $TMPDIR

# A simple delta timer (seconds)
mytime () 
{
    now=`date +"%s"`
    if (( $# > 0 )); then
        rtn=`python -c "print($now - $1)"`
    else
       rtn=$now
    fi
    echo $rtn
}
   
date
st=`mytime`
now=$st

# Clean out an old spack
rm -rf spack
git clone -c feature.manyFiles=true https://github.com/spack/spack.git  

export SPACK_USER_CONFIG_PATH=`pwd`/.myspack  
#fstr='dospack () { export TMPDIR='${MYDIR}'/tmp ; export SPACK_USER_CONFIG_PATH='${WORKDIR}'/.myspack ; source '${WORKDIR}'/spack/share/spack/setup-env.sh ; }' ; eval $fstr
fstr='dospack () {                                 export SPACK_USER_CONFIG_PATH='${WORKDIR}'/.myspack ; source '${WORKDIR}'/spack/share/spack/setup-env.sh ; }' ; eval $fstr

echo Settings:
echo To restart spack to add more packages create this function and run it.
echo Then just do a spack install.
echo $fstr > dospack.func
printenv | egrep "^WORKDIR|^MYDIR|^SLURM_SUBMIT_DIR|^SLURM_JOB_ID" | sed "s/^/export /" > dirsettings
dospack


spack compiler find
clist=`spack compiler list | grep @`
#for c in $clist ; do if [[ ${c} != *"12"* ]];then spack compiler remove $c ; fi; done


# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml


echo Time to setup spack: $(mytime $now)


now=`mytime`

spack install gcc
spack install aspell

# Create upstreams.yaml for next level

cat > $WORKDIR/upstreams.tmp << HERE
upstreams:
  level01:
    install_tree: LEVEL01/install/opt/spack
    modules:
            lmod: MODPATH
HERE


MODPATH=`find $MYDIR/modules -name aspell`
MODPATH=`dirname $MODPATH`
sed "s,LEVEL01,$MYDIR," $WORKDIR/upstreams.tmp  | sed "s,MODPATH,$MODPATH," > $WORKDIR/upstreams.yaml


echo Time to install gcc: $(mytime $now)


# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml


echo Time to setup spack: $(mytime $now)

# local copy of munge
mkdir -p $STARTDIR/munge/lib
mkdir -p $STARTDIR/munge/include
cp $STARTDIR/munge.h $STARTDIR/munge/include
ln -s /usr/lib64/libmunge.so.2 $STARTDIR/munge/lib/.
ln -s /usr/lib64/libmunge.so.2 $STARTDIR/munge/lib/libmunge.so
sed "s,STARTDIR,$STARTDIR," $STARTDIR/packages.tmp > $STARTDIR/packages.yaml

# add other locals
cp spack/etc/spack/defaults/packages.yaml spack/etc/spack/defaults/packages.`stamp`
cat $STARTDIR/packages.yaml >> spack/etc/spack/defaults/packages.yaml



now=`mytime`

spack install slurm +hwloc

spack load slurm

spack external find slurm
spack install ucx +verbs  +rc +ud +mlx5_dv

:<<++++
If --reuse does not work this will 
++++

cp $WORKDIR/spack/etc/spack/defaults/packages.yaml $WORKDIR/spack/etc/spack/defaults/packages.yaml`stamp`
UCX_INFO=`find $MYDIR -name ucx_info | grep 1.12.1`
UCX_BIN=`dirname $UCX_INFO`
UCX_PATH=`dirname $UCX_BIN`

cat << UCX >> $WORKDIR/spack/etc/spack/defaults/packages.yaml
  ucx:
    externals:
    - spec: "ucx@1.12.1"
      prefix: $(echo $UCX_PATH)
UCX

spack install openmpi@4.1.3 fabrics=ucx schedulers=slurm pmi=true static=false

echo Time to install openmpi: $(mytime $now)



now=`mytime`
spack install nvhpc +blas +mpi +lapack

echo Time to install nvhpc: $(mytime $now)

now=`mytime`

spack install intel-oneapi-compilers
spack install intel-oneapi-mpi intel-oneapi-ccl  intel-oneapi-dal intel-oneapi-dnn intel-oneapi-ipp intel-oneapi-ippcp intel-oneapi-mkl intel-oneapi-tbb intel-oneapi-vpl

echo Time to install intel: $(mytime $now)

now=`mytime`
spack install git
spack install gmake
spack install cmake
echo Time to install tools: $(mytime $now)


if [[ ! -d myrepo ]];then
  spack repo create myrepo
  #spack repo add $NOWDIR/myrepo
  spack repo add myrepo
fi
if test -f "$SLURM_SUBMIT_DIR/julia.py"; then
  mkdir -p myrepo/packages/julia
  cp $SLURM_SUBMIT_DIR/julia.py  myrepo/packages/julia/package.py
fi 
now=`mytime`
spack install julia
echo Time to install julia: $(mytime $now)

spack install python@3.10.2 +tkinter

echo Time to install python: $(mytime $now)

spack load python
which python

python -m pip install update
python -m pip install --upgrade pip
which pip3

pip3 install matplotlib
pip3 install pandas
pip3 install scipy
pip3 install jupyterlab
pip3 install reframe-hpc
pip3 install pygelf


echo Time to install python extras: $(mytime $now)

now=`mytime`

#now=`mytime`
#spack install libjpeg
#spack install libpng
#spack install r
#echo Time to install r: $(mytime $now)

echo Total time: $(mytime $st)
cp $SLURM_SUBMIT_DIR/*$SLURM_JOBID* $MYDIR 
