#!/bin/bash
#SBATCH --job-name="hybrid"
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=01:00:00
#SBATCH --partition=debug
##SBATCH --output=system_build
##SBATCH --error=system_build

# Example on how you would add packages to an install

#Get these from the output file or the runscript
export STARTDIR=`pwd`

# This line must be changed.
export MYDIR=/projects/hpcapps/220419a/level00

#Create a function to start spack
fstr='dospack () { export TMPDIR='${MYDIR}'/tmp ; export SPACK_USER_CONFIG_PATH='${STARTDIR}'/myspack/level00/.myspack ; source '${STARTDIR}'/myspack/level00/spack/share/spack/setup-env.sh ; }' ; eval $fstr

#Save a copy of the function
declare -f dospack > dospack.func

printenv |egrep "STARTDIR|MYDIR"
printenv |egrep "^STARTDIR|^MYDIR" | sed "s/^/export /" > dirsettings

#Start spack
dospack

spack compiler list
spack install r
#Rscript rstall.R 

