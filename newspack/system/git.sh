#!/bin/bash

STARTDIR=`pwd`
echo $STARTDIR

export MYDIR=~/bin/boot2

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

cp $STARTDIR/git.sh  $MYDIR/$BUILDDIR.script
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


CWD=`pwd`

fstr='dospack () {  export SPACK_USER_CONFIG_PATH='${CWD}'/myconfig ; source '${CWD}'/spack/share/spack/setup-env.sh ; spack bootstrap root --scope defaults '${CWD}'/myboot ; }' ; eval $fstr
echo $fstr > dospack.func


echo Settings:
echo To restart spack to add more packages add these lines to ~/.bashrc or source them
echo export MYDIR=$MYDIR
echo export TMPDIR=$TMPDIR
ml
cat dospack.func
dospack
# Start spack


# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml


echo Time to setup spack: $(mytime $now)




now=`mytime`

# git also installs curl
spack install git
spack install wget

echo Time to install utilities: $(mytime $now)

echo Total time: $(mytime $st)

