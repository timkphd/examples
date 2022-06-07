#!/bin/bash
#SBATCH --job-name="buildgcc"
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=04:00:00
##SBATCH --partition=sm
##SBATCH --output=system_build
##SBATCH --error=system_build

module purge
module use /nopt/nrel/apps/220511a/modules/lmod/linux-centos7-x86_64/gcc/12.1.0/
module load git
module load gcc
module load python

stamp () { date +"%y%m%d%H%M%S"; }
export WORKDIR=`stamp`
mkdir $WORKDIR
cd $WORKDIR
export WORKDIR=`pwd`

export MYDIR=/nopt/nrel/apps/220525b/level00
rm -rf $MYDIR
mkdir -p $MYDIR

cat $0 > script.$WORKDIR
cat $0 > $MYDIR/script.$WORKDIR

echo export WORKDIR=$WORKDIR
echo export MYDIR=$MYDIR

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

# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml


echo Time to setup spack: $(mytime $now)


now=`mytime`
export CV=$(gcc -v 2>&1 | tail -1 | awk '{print $3}')

spack install gcc
spack install aspell

# Create upstreams.yaml for next level

cat > $WORKDIR/upstreams.tmp << HERE
upstreams:
  level00:
    install_tree: LEVEL00/install/opt/spack
    modules:
            lmod: MODPATH
HERE


MODPATH=`find $MYDIR/modules -name aspell`
MODPATH=`dirname $MODPATH`
sed "s,LEVEL00,$MYDIR," $WORKDIR/upstreams.tmp  | sed "s,MODPATH,$MODPATH," > $WORKDIR/upstreams.yaml

echo Total time: $(mytime $st)

cp $SLURM_SUBMIT_DIR/*$SLURM_JOB_ID* $MYDIR
