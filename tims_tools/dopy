#!/bin/bash
#SBATCH --job-name="buildpython"
#SBATCH --nodes=1
#SBATCH --partition=debug
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=01:00:00

# make sure we have git
which git 2> /dev/null || ml git

# Simple timer
mytime () 
{ 
    now=`date +"%s.%N"`;
    if (( $# > 0 )); then
        rtn=$(printf "%0.3f" `echo $now - $1 | bc`);
    else
        rtn=$(printf "%0.3f" `echo $now`);
    fi;
    echo $rtn
}

# Where are we?
cd `realpath -P .`
STARTDIR=`pwd`
echo $STARTDIR

# MDY is used as the build directory relative to
# the starting directory and as the subdirectory
# or the install.  It's a date stamp with a trailing
# lettter.

export LETTER=t
if [ -z "$LETTER" ]  ; then export LETTER=a;fi
export MDY=`date +%m%d%y_$LETTER`
BASED=/kfs2/projects/hpcapps/pythons
if [ -z "$BASED" ]  ; then export BASED=/lustre/eaglefs/scratch/tkaiser2/shared/python ;fi
export BIRD=${BASED}/${MDY}

echo $BIRD
echo $MDY

rm -rf $BIRD
rm -rf $MDY
mkdir -p $BIRD
mkdir $MDY

# get patches 
ls setinstall 2>/dev/null || wget https://raw.githubusercontent.com/timkphd/examples/master/tims_tools/setinstall
chmod 755 setinstall
ls tkinter 2>/dev/null    || wget https://raw.githubusercontent.com/timkphd/examples/master/tims_tools/tkinter
 
# save our environment in the build and install directories
cat $0 > $BIRD/build_script
cp setinstall $BIRD
printenv > $BIRD/env

cat $0 > $MDY/build_script
cp setinstall $MDY
printenv > $MDY/env

st=`mytime`
now=$st

cd $MDY
git clone https://github.com/spack/spack.git  
cd spack
#if dev version fails do this
#git checkout 2023-04-05
export SPACK_ROOT=`pwd`
export SPACK_USER_CONFIG_PATH=${SPACK_ROOT}/.spack
export SPACK_USER_CACHE_PATH=${SPACK_ROOT}/.cache
export TMPDIR=$SPACK_ROOT/tmp
mkdir -p $TMPDIR

$STARTDIR/setinstall `realpath -P etc/spack/defaults` `realpath $BIRD`
source $STARTDIR/tkinter || echo tkinter patch not installed
source share/spack/setup-env.sh


ml gcc
ml python
ml gmake
spack compiler find
#spack external find
spack external find sqlite
spack info python
# as of 04/25/24
#    3.12.1     https://www.python.org/ftp/python/3.12.1/Python-3.12.1.tgz
#    3.11.7     https://www.python.org/ftp/python/3.11.7/Python-3.11.7.tgz
#    3.10.13    https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz
#    3.9.18     https://www.python.org/ftp/python/3.9.18/Python-3.9.18.tgz


for pack in  "python@3.11.7 +tkinter" "python@3.12.1 +tkinter"  ; do
#for pack in  "python"  ; do

echo installing $pack
now=`mytime`
#spack install --no-check-signature --no-checksum $pack
spack install $pack
echo Time to install $pack: $(mytime $now)
done

#report on install
echo export STARTDIR=$STARTDIR
echo export SPACK_ROOT=$SPACK_ROOT
echo export SPACK_USER_CONFIG_PATH=$SPACK_ROOT/.spack
echo export SPACK_USER_CACHE_PATH=$SPACK_ROOT/.cache
echo export TMPDIR=$SPACK_ROOT/tmp
echo source $SPACK_ROOT/share/spack/setup-env.sh
echo Install directory \$BIRD=$BIRD
cd $STARTDIR
echo "modules in:"
BASE=$BIRD
#find our module directory
LDIR=$(for x in `find $BASE/lmod -type f` ; do dirname `dirname $x` ; done | sort -u | grep lmod)
echo $LDIR


#install stuff in our base python
module use $LDIR
ml python
which python 

pipit() {
rm -rf get-pip.py
wget  https://bootstrap.pypa.io/get-pip.py
which python
python get-pip.py
pip install --upgrade  --no-cache-dir pip
pip3 install  --no-cache-dir matplotlib
pip3 install  --no-cache-dir pyarrow
pip3 install  --no-cache-dir pandas
pip3 install  --no-cache-dir scipy
pip3 install  --no-cache-dir jupyterlab
pip3 install  --no-cache-dir reframe-hpc
}

pipit

 
#create a new python based on our installed version
#NEWPY & NEWDIR can be anything
export NEWPY=mypie
export NEWDIR=`pwd`

rm -rf $NEWDIR/$NEWPY

python -m venv  $NEWDIR/$NEWPY
source  $NEWDIR/$NEWPY/bin/activate

#install stuff in our new python
which python
pipit

#do mpi4py and hdf5
#ml intel-mpi
#pip install --no-cache-dir mpi4py==3.1.4
pip install --no-cache-dir mpi4py

: << SKIP
# hdr5 appears to be broken for latest version of mpi4py and python3.12
ml hdf5/1.12.0/intel-impi
export CC=mpiicc
export HDF5_MPI="ON"
export HDF5_DIR=/nopt/nrel/apps/hdf5/1.12.0-intel-impi
#rm -rf h5py
#git clone https://github.com/h5py/h5py.git
#cd h5py
#pip install .
pip install  --no-cache-dir --no-binary=h5py h5py
SKIP


echo to use your new python:
echo source $NEWDIR/$NEWPY/bin/activate
