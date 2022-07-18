#!/bin/bash
#SBATCH --job-name="hybrid"
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=4:00:00
#SBATCH --partition=short
#SBATCH --output=opnfm_build
#SBATCH --error=opnfm_build


shopt -s expand_aliases
STARTDIR=`pwd`
echo $STARTDIR

export MYDIR=/lustre/eaglefs/scratch/tkaiser2/openfoam/build15

# Select an install directory.
# WARNING: this directory will be cleaned out before
# the install.
if [ -z "$MYDIR" ]  ;     then
#    export MYDIR=/projects/hpcapps/opnfm/0316
    if [ -n "$BASE" ] ; then
        export MYDIR=$BASE/opnfm/$(date +%g%m%d)
    else
# Putting this in home will most likely fill it up
        export MYDIR=$HOME/opnfm/$(date +%g%m%d)
        echo WARNING: putting opnfm in $HOME
    fi
fi
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
   
stamp ()  {  date +"%y%m%d%H%M%S" ; }

cp $0  $MYDIR/`stamp`.script
date
st=`mytime`
now=$st


# We'll do the build here relative to this script
mkdir -p myspack/level00
cd myspack/level00

# Clean out an old spack
rm -rf spack
git clone -c feature.manyFiles=true https://github.com/spack/spack.git  
module unload conda /dev/null 2>&1 || echo "conda not loaded"


export SPACK_USER_CONFIG_PATH=`pwd`/.myspack  
alias dospack="source `pwd`/spack/share/spack/setup-env.sh"  

echo Settings:
echo To restart spack to add more packages add these two lines to ~/.bashrc or source them
alias | grep dospack
echo "export SPACK_USER_CONFIG_PATH=$SPACK_USER_CONFIG_PATH"
echo export MYDIR=$MYDIR
echo export TMPDIR=$TMPDIR
# Start spack
source `pwd`/spack/share/spack/setup-env.sh  

ml gcc  > /dev/null 2>&1 || echo "no gcc module"


# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml

cp spack/etc/spack/defaults/packages.yaml spack/etc/spack/defaults/packages.$backup
cat spack/etc/spack/defaults/packages.$backup $STARTDIR/packages.yaml > spack/etc/spack/defaults/packages.yaml

echo Time to setup spack: $(mytime $now)

ml openmpi/4.1.1/gcc+cuda
ml gcc

spack compiler find

now=`mytime`

spack install openfoam


echo "Here are the module directories"

echo module use $(dirname $(find $MYDIR/modules -name perl))
echo module use $(dirname $(find $MYDIR/modules -name openfoam))

echo "Copy/paste the two lines above to your terminal.:"
echo "You may want to add these to your .bashrc file."
echo
echo "The modules in the second directory will need to be modified."
echo 'Take out the line that starts --depends_on("openmpi '
echo

echo "After that you should be able to:"
echo "ml openfoam"
echo
echo "You will also need to:"
echo "ml openmpi/4.1.1/gcc+cuda"
echo "ml gcc"



