#!/bin/bash
STARTDIR=`pwd`
echo $STARTDIR

cat > packages.tmp << HERE
  munge:
    externals:
    - spec: "munge@0.5.14"
      prefix: STARTDIR/munge
  perl:
    externals:
    - spec: "perl@5.34.1"
      prefix: /usr
  curl:
    externals:
    - spec: "curl@7.83.0"
      prefix: /usr/bin
  tar:
    externals:
    - spec: "tar@1.3.4"
      prefix: /usr/bin
  xz:
    externals:
    - spec: "xz@5.2.5"
      prefix: /usr/bin
  python:
    externals:
    - spec: "python@3.9.12"
      prefix: /nopt/nrel/apps/210928a/level00/gcc-9.4.0/python-3.9.6
  cmake:
    externals:
    - spec: "cmake@3.23.1"
      prefix: /usr
  openssl:
    externals:
    - spec: "openssl@1.1.1o"
      prefix: /usr
HERE


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
   

date
st=`mytime`
now=$st


# We'll do the build here relative to this script
stamp ()  {  date +"%y%m%d%H%M%S" ; }
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
echo "#Settings:"                 > dirsettings
echo export STARTDIR=$STARTDIR   >> dirsettings
echo export MYDIR=$MYDIR         >> dirsettings
echo export TMPDIR=$TMPDIR       >> dirsettings

ml
# Start spack
dospack


# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml


echo Time to setup spack: $(mytime $now)

# local copy of munge
mkdir -p $STARTDIR/munge/lib
mkdir -p $STARTDIR/munge/include
cp $STARTDIR/munge.h $STARTDIR/munge/include
ln -s /usr/lib64/libmunge.so.2 $STARTDIR/munge/lib/.
ln -s /usr/lib64/libmunge.so.2 $STARTDIR/munge/lib/libmunge.so
sed "s,STARTDIR,$STARTDIR," $STARTDIR/packages.tmp > $STARTDIR/packages.yaml

# add other locals
cp spack/etc/spack/defaults/packages.yaml spack/etc/spack/defaults/packages.`stamp`
cat $STARTDIR/packages.yaml >> spack/etc/spack/defaults/packages.yaml



now=`mytime`

spack install slurm +hwloc

echo Time to install slurm: $(mytime $now)

# Create upstreams.yaml for next level

cat > $STARTDIR/upstreams.tmp << HERE
upstreams:
  level00:
    install_tree: LEVEL00/install/opt/spack
    modules:
            lmod: MODPATH
HERE


MODPATH=`find $MYDIR/modules -name slurm`
MODPATH=`dirname $MODPATH`
sed "s,LEVEL00,$MYDIR," $STARTDIR/upstreams.tmp  | sed "s,MODPATH,$MODPATH," > $STARTDIR/upstreams.yaml
cd $STARTDIR
echo Total time: $(mytime $st)

