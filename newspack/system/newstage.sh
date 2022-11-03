#!/bin/bash
#SBATCH --job-name="hybrid"
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=08:00:00
#SBATCH --partition=standard
##SBATCH --output=system_build
##SBATCH --error=system_build

module purge
module use /home/tkaiser2/bin/boot/modules/lmod/linux-centos7-x86_64/Core
module load git
module load curl
module load wget
module load gcc
#module load python  > /dev/null 2>&1 || echo "python module not found"
#git --version > /dev/null 2>&1 || ml conda
#module load slurm

export STARTDIR=`pwd`
echo $STARTDIR

export MYDIR=/nopt/nrel/apps/220511a

# Select an install directory.
# WARNING: this directory will be cleaned out before
# the install.
if [ -z "$MYDIR" ]  ;     then
#    export MYDIR=/projects/hpcapps/julia/0316
    if [ -n "$BASE" ] ; then
        export MYDIR=$BASE/julia/$(date +%g%m%d)
    else
# Putting this in home will most likely fill it up
        export MYDIR=$HOME/julia/$(date +%g%m%d)
        echo WARNING: putting julia in $HOME
    fi
fi
rm -rf $MYDIR
mkdir -p $MYDIR


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
   
stamp ()  {  date +"%y%m%d%H%M%S" ; }

export BUILDDIR=`stamp`

cp $0  $MYDIR/$BUILDDIR.script
date
st=`mytime`
now=$st


# We'll do the build here relative to this script
rm -rf myspack/$BUILDDIR
mkdir -p myspack/$BUILDDIR
cd myspack/$BUILDDIR

# Clean out an old spack
rm -rf spack
git clone -c feature.manyFiles=true https://github.com/spack/spack.git  
module unload conda /dev/null 2>&1 || echo "conda not loaded"


CWD=`pwd`

fstr='dospack () {  export SPACK_USER_CONFIG_PATH='${CWD}'/myconfig ; source '${CWD}'/spack/share/spack/setup-env.sh ; spack bootstrap root --scope defaults '${CWD}'/myboot ; }' ; eval $fstr
echo $fstr > dospack.func
egrep "^STARTDIR|^MYDIR" | sed "s/^/export /" > dirsettings


echo Settings:
echo To restart spack to add more packages add these lines to ~/.bashrc or source them
echo export MYDIR=$MYDIR
echo export TMPDIR=$TMPDIR
ml
cat dospack.func
dospack
# Start spack

#ml gcc  > /dev/null 2>&1 || echo "no gcc module"

spack compiler find

# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml


echo Time to setup spack: $(mytime $now)




now=`mytime`
export CV=$(gcc -v 2>&1 | tail -1 | awk '{print $3}')

spack install gcc

echo Time to install gcc: $(mytime $now)

export mpath=$(dirname $(find $MYDIR/modules -name bzip2 | tail -1))
module use $mpath
ml gcc
#git --version > /dev/null 2>&1 || ml conda
spack compiler find
clist=`spack compiler list | grep @`
for c in $clist ; do if [[ ${c} != *"12"* ]];then spack compiler remove $c ; fi; done

now=`mytime`

spack install gcc

echo Time to install gcc: $(mytime $now)

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
if test -f "$STARTDIR/julia.py"; then
  mkdir -p myrepo/packages/julia
  cp $STARTDIR/julia.py  myrepo/packages/julia/package.py
fi 
now=`mytime`
spack install julia
echo Time to install julia: $(mytime $now)

# Find the module directory
LMODDIR=$(dirname $(find $MYDIR/modules/lmod -name "julia*"))

echo "To enable your modules add the following to your .bashrc file or source it"

echo module use $LMODDIR

module use $LMODDIR

# Did it work?
module unload gcc
module load julia
which julia

# to not also build python and Jupyter uncomment the next line
#exit

# Install some python stuff, ending in jupyterlab
# Install pip3
now=`mytime`

module load gcc
spack install python@3.10.2 +tkinter

echo Time to install python: $(mytime $now)

module load python
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
spack external find slurm
spack install ucx +verbs  +rc +ud +mlx5_dv

:<<++++
If --reuse does not work this will 
++++

cp $STARTDIR/myspack/$BUILDDIR/spack/etc/spack/defaults/packages.yaml $STARTDIR/myspack/$BUILDDIR/spack/etc/spack/defaults/packages.yaml`stamp`
UCX_INFO=`find $MYDIR -name ucx_info | grep 1.12.1`
UCX_BIN=`dirname $UCX_INFO`
UCX_PATH=`dirname $UCX_BIN`

cat << UCX >> $STARTDIR/myspack/$BUILDDIR/spack/etc/spack/defaults/packages.yaml
  ucx:
    externals:
    - spec: "ucx@1.12.1"
      prefix: $(echo $UCX_PATH)
UCX

spack install --reuse openmpi@4.1.3 fabrics=ucx schedulers=slurm pmi=true static=false +cuda +java


echo Time to install openmpi: $(mytime $now)

now=`mytime`
spack install libjpeg
spack install libpng
spack install r
echo Time to install r: $(mytime $now)

echo Total time: $(mytime $st)
cp $STARTDIR/slurm*$SLURM_JOBID* $MYDIR 

