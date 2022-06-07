#!/bin/bash



STARTDIR=`pwd`
echo $STARTDIR
#The script will fail if these are not installed /usr/bin
cat > packages.tmp << HERE
  autoconf:
    externals:
    - spec: "autoconf@2.69"
      prefix: /usr/bin
  automake:
    externals:
    - spec: "automake@1.16.5"
      prefix: /usr/bin
  libtool:
    externals:
    - spec: "libtool@2.4.7"
      prefix: /usr/bin
  m4:
    externals:
    - spec: "m4@1.4.19"
      prefix: /usr
  hdf5:
    externals:
    - spec: "hdf5@1.13.1"
      prefix: /nopt/nrel/apps/hdf5/1.12.0-intel-impi
HERE

module purge 
export MODULEPATH=/nopt/nrel/apps/220525b/level02/modules/lmod/linux-rocky8-x86_64/intel-oneapi-mpi/2021.6.0-ghyk7n2/gcc/12.1.0:/nopt/nrel/apps/220525b/level01/modules/lmod/linux-rocky8-x86_64/gcc/12.1.0:/opt/ohpc/pub/modulefiles
export MODULEPATH=/nopt/nrel/apps/220525b/level02/modules/lmod/linux-centos7-x86_64/intel-oneapi-mpi/2021.6.0-r7lacq7/gcc/12.1.0:/nopt/nrel/apps/220525b/level01/modules/lmod/linux-centos7-x86_64/gcc/12.1.0

module load  autoconf automake libtool m4  gcc hdf5 
module load git || echo "git module not found"


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
export BUILDDIR=intelmpi_hdf
export MYDIR=$BUILDDIR
export MYDIR=/nopt/nrel/apps/220525b/level03b

mkdir -p $MYDIR
#export TMPDIR=$MYDIR/tmp
#mkdir -p $TMPDIR

mkdir $BUILDDIR
cd $BUILDDIR

# git spack
git clone -c feature.manyFiles=true https://github.com/spack/spack.git  


CWD=`pwd`

fstr='dospack () {  export SPACK_USER_CONFIG_PATH='${CWD}'/myconfig ; source '${CWD}'/spack/share/spack/setup-env.sh ; spack bootstrap root --scope defaults '${CWD}'/myboot ; }' ; eval $fstr
echo "#function to restart spack" > dospack.func
echo $fstr >> dospack.func
echo "#Settings:"                 > dirsettings
echo export BUILDDIR=$BUILDDIR   >> dirsettings
echo export STARTDIR=$STARTDIR   >> dirsettings
echo export MYDIR=$MYDIR         >> dirsettings
echo export TMPDIR=$TMPDIR       >> dirsettings
cp dospack.func dirsettings $MYDIR

# Start spack
dospack

# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml

#cat $STARTDIR/packages.tmp >> spack/etc/spack/defaults/packages.yaml
#rm $STARTDIR/packages.tmp

cp $STARTDIR/upstreams.intel  spack/etc/spack/defaults/upstreams.yaml
echo Time to setup spack: $(mytime $now)



# Make sure we intelmpi available
module load intel-oneapi-mpi
# Here is the install
spack install ior +hdf5 ^intel-oneapi-mpi

now=`mytime`
echo Time to install ior: $(mytime $now)


MODPATH=`find $MYDIR/modules -name ior`
MODPATH=`dirname $MODPATH`
echo Module path: $MODPATH

cd $STARTDIR

echo Total time: $(mytime $st)

