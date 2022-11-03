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
export BUILDDIR=`stamp`
export BUILDDIR=here
export MYDIR=$BUILDDIR/level00

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
# Start spack
dospack


# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml


echo Time to setup spack: $(mytime $now)




now=`mytime`

spack install aspell

echo Time to install aspell: $(mytime $now)

# Create upstreams.yaml for next level

cat > $STARTDIR/upstreams.tmp << HERE
upstreams:
  level00:
    install_tree: LEVEL00/install/opt/spack
    modules:
            lmod: MODPATH
HERE


MODPATH=`find $MYDIR/modules -name aspell`
MODPATH=`dirname $MODPATH`
sed "s,LEVEL00,$MYDIR," $STARTDIR/upstreams.tmp  | sed "s,MODPATH,$MODPATH," > $STARTDIR/upstreams.yaml
cd $STARTDIR
echo Total time: $(mytime $st)

