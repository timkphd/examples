#!/bin/bash
#SBATCH --job-name="hybrid"
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=24:00:00
#SBATCH --partition=gpu
##SBATCH --output=system_build
##SBATCH --error=system_build

module use /nopt/nrel/apps/boot/base/nopt/modules/lmod/linux-rocky8-x86_64/Core
module load gcc
module load python
module unload openssl

mkdir base 
cd base
rm -rf spack
git clone -c feature.manyFiles=true https://github.com/spack/spack.git  
export STARTDIR=`pwd`
export MYDIR=$STARTDIR/nopt
mkdir $MYDIR
export SPACK_USER_CONFIG_PATH=$STARTDIR/.myspack 
export BOOT=$STARTDIR/.spack_boot
#export TMPDIR=$STARTDIR/tmp ; mkdir $TMPDIR
fstr='dospack () {  export SPACK_USER_CONFIG_PATH='${STARTDIR}'/.myspack ; source '${STARTDIR}'/spack/share/spack/setup-env.sh ; spack bootstrap root --scope defaults '${BOOT}' ; }' ; eval $fstr
echo $fstr > dospack.func

# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml
#cat >>  spack/etc/spack/defaults/modules.yaml  <<HERE
#      core_compilers:
#      - gcc@11.3.0
#HERE

dospack

spack install wget
spack install gcc@11.3.0
spack install python@3.9.12
spack install python@3.10.4

