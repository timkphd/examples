#!/bin/bash
#SBATCH --job-name="hybrid"
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=1:00:00
#SBATCH --partition=debug
#SBATCH --output=r_build
#SBATCH --error=r_build


stamp ()  {  date +"%y%m%d%H%M%S" ; }
doday () {  date +"%y%m%d" ; }
shopt -s expand_aliases
STARTDIR=`pwd`
echo $STARTDIR

export XDIR=`doday`

export MYDIR=/lustre/eaglefs/scratch/tkaiser2/r/$XDIR

rm -rf $MYDIR
mkdir -p $MYDIR


export TMPDIR=$MYDIR/tmp
mkdir -p $TMPDIR

module purge
module load python  > /dev/null 2>&1 || echo "python module not found"
git --version > /dev/null 2>&1 || ml conda

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
   

cp $0  $MYDIR/`stamp`.script
date
st=`mytime`
now=$st


# We'll do the build here relative to this script
mkdir -p $XDIR/level00
cd $XDIR/level00

# Clean out an old spack
rm -rf spack
git clone -c feature.manyFiles=true https://github.com/spack/spack.git  
cd spack
#git checkout b431c4dc06ec0757b00b6f790be25b601f774a53
module unload conda /dev/null 2>&1 || echo "conda not loaded"
# Modify the config files to point to the install directory and to make lmod modules
$STARTDIR/setinstall `realpath -P etc/spack/defaults` `realpath $MYDIR`

export SPACK_USER_CONFIG_PATH=`pwd`/.$XDIR  
alias dospack="source `pwd`/share/spack/setup-env.sh"  

echo Settings:
echo To restart spack to add more packages add these two lines to ~/.bashrc or source them
alias | grep dospack
echo "export SPACK_USER_CONFIG_PATH=$SPACK_USER_CONFIG_PATH"
echo export MYDIR=$MYDIR
echo export TMPDIR=$TMPDIR
# Start spack
source `pwd`/share/spack/setup-env.sh  

ml gcc  > /dev/null 2>&1 || echo "no gcc module"



echo Time to setup spack: $(mytime $now)

ml gcc

spack compiler find

now=`mytime`

#spack install aspell
spack install r


echo "Here are the module directories"

#echo module use $(dirname $(find $MYDIR/lmod -name aspell))
echo module use $(dirname $(find $MYDIR/lmod -name perl))
mpath=`echo $(dirname $(find $MYDIR/lmod -name perl))`
echo "Copy/paste the module use above to your terminal.:"
echo "You may want to add these to your .bashrc file."
echo
echo

module use $mpath
module load r
which R
echo installing packages
cat $STARTDIR/doinstall.R
R -f $STARTDIR/doinstall.R > $STARTDIR/install.log 2>&1

