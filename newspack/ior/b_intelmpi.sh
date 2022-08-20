#!/bin/bash



STARTDIR=`pwd`
echo $STARTDIR
#The script will fail if these are not installed /usr/bin
cat > packages.tmp << HERE
  autoconf:
    externals:
    - spec: "autoconf@2.69"
      prefix: /nopt/nrel/apps/210929a/level00/gcc-9.4.0/autoconf-2.69/bin
  automake:
    externals:
    - spec: "automake@1.16.5"
      prefix: /nopt/nrel/apps/210929a/level00/gcc-9.4.0/automake-1.16.3/bin
  libtool:
    externals:
    - spec: "libtool@2.4.7"
      prefix: /nopt/nrel/apps/210929a/level00/gcc-9.4.0/libtool-2.4.6/bin
  m4:
    externals:
    - spec: "m4@1.4.19"
      prefix: /nopt/nrel/apps/210929a/level00/gcc-9.4.0/m4-1.4.19
HERE

ml autoconf automake libtool m4  gcc 


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
export BUILDDIR=intelmpi
export MYDIR=$BUILDDIR

rm -rf $MYDIR
mkdir -p $MYDIR
cd $MYDIR
export MYDIR=`pwd`
#export TMPDIR=$MYDIR/tmp
#mkdir -p $TMPDIR

cd $MYDIR

# git spack
git clone -c feature.manyFiles=true https://github.com/spack/spack.git  


CWD=`pwd`

fstr='dospack () {  export SPACK_USER_CONFIG_PATH='${CWD}'/myconfig ; source '${CWD}'/spack/share/spack/setup-env.sh ; spack bootstrap root --scope defaults '${CWD}'/myboot ; }' ; eval $fstr
echo "#function to restart spack" > dospack.func
echo $fstr >> dospack.func
echo "#Settings:"                 > dirsettings
echo export STARTDIR=$STARTDIR   >> dirsettings
echo export MYDIR=$MYDIR         >> dirsettings
echo export TMPDIR=$TMPDIR       >> dirsettings

# Start spack
dospack


# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml

cat $STARTDIR/packages.tmp >> spack/etc/spack/defaults/packages.yaml
rm $STARTDIR/packages.tmp
echo Time to setup spack: $(mytime $now)



# Make sure we intelmpi available
spack install intel-oneapi-mpi
spack load intel-oneapi-mpi
# Here is the install
spack install ior ^intel-oneapi-mpi

now=`mytime`
echo Time to install ior: $(mytime $now)


MODPATH=`find $MYDIR/modules -name ior`
MODPATH=`dirname $MODPATH`
echo Module path: $MODPATH

cd $STARTDIR
echo Total time: $(mytime $st)

