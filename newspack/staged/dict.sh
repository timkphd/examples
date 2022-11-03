#!/bin/bash

STARTDIR=`pwd`
echo $STARTDIR


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
   

date
st=`mytime`
now=$st


# We'll do the build here relative to this script
export BUILDDIR=here
export MYDIR=$BUILDDIR/level01

rm -rf $MYDIR
mkdir -p $MYDIR
cd $MYDIR
export MYDIR=`pwd`
export TMPDIR=$MYDIR/tmp
mkdir -p $TMPDIR

cd $MYDIR

# Clean out an old spack
rm -rf spack
git clone -c feature.manyFiles=true https://github.com/spack/spack.git  


CWD=`pwd`

fstr='dospack () {  export SPACK_USER_CONFIG_PATH='${CWD}'/myconfig ; source '${CWD}'/spack/share/spack/setup-env.sh ; spack bootstrap root --scope defaults '${CWD}'/myboot ; }' ; eval $fstr
echo "#function to restart spack" > dospack.func
echo $fstr >> dospack.func
echo "#Settings:"           > dirsettings
echo export MYDIR=$MYDIR   >> dirsettings
echo export TMPDIR=$TMPDIR >> dirsettings

ml
cat dospack.func
# Start spack
dospack


# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml

cp $STARTDIR/upstreams.yaml spack/etc/spack/defaults
echo Time to setup spack: $(mytime $now)




now=`mytime`

#spack install aspell
spack install aspell6-en
echo Time to install aspell: $(mytime $now)

cd $STARTDIR


# Save the module paths for our new software
BASE=`cat here/level00/spack/etc/spack/defaults/modules.yaml | grep level | grep lmod | awk '{print $NF}'`
MODPATH=$(dirname $(find $BASE -name "*spell*"))
echo module use $MODPATH > module_use
BASE=`cat here/level01/spack/etc/spack/defaults/modules.yaml | grep level | grep lmod | awk '{print $NF}'`
MODPATH=$(dirname $(find $BASE -name "*spell*"))
echo module use $MODPATH >> module_use

echo Total time: $(mytime $st)




