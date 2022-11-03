#!/bin/bash



STARTDIR=`pwd`
echo $STARTDIR
#The script will fail if these are not installed /usr/bin
cat > packages.tmp << HERE
  autoconf:
    externals:
    - spec: "autoconf@2.69"
      prefix: /nopt/nrel/apps/220525b/level01/install/opt/spack/linux-rocky8-zen2/gcc-12.1.0/autoconf-2.69-n4yqgbjqoqqs2psmjq6wy3h7nc5m73z5/bin
  automake:
    externals:
    - spec: "automake@1.16.5"
      prefix: /nopt/nrel/apps/220525b/level01/install/opt/spack/linux-rocky8-zen2/gcc-12.1.0/automake-1.16.5-ejontxenhxgc2i2u5sj4ocg6eooputln/bin
  libtool:
    externals:
    - spec: "libtool@2.4.7"
      prefix: /nopt/nrel/apps/220525b/level01/install/opt/spack/linux-rocky8-zen2/gcc-12.1.0/libtool-2.4.7-nvqxkrs7yae7tmtfh4mvnfcpnaxfrudm/bin
  m4:
    externals:
    - spec: "m4@1.4.19"
      prefix: /nopt/nrel/apps/220525b/level01/install/opt/spack/linux-rocky8-zen2/gcc-12.1.0/m4-1.4.19-jmuhtafv2w74jmvietl7zfv7q7vfa2qp
HERE

module purge
module use /nopt/nrel/apps/220525b/level01/modules/lmod/linux-centos7-x86_64/gcc/12.1.0/

module load  autoconf automake libtool m4 gcc 
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
export BUILDDIR=hdf5
export MYDIR=$BUILDDIR
export MYDIR=/nopt/nrel/apps/220525b/level02x

rm -rf $MYDIR
mkdir -p $MYDIR
cd $MYDIR
export MYDIR=`pwd`
export TMPDIR=$MYDIR/tmp
mkdir -p $TMPDIR

cd $BUILDDIR

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

#cat $STARTDIR/packages.tmp >> spack/etc/spack/defaults/packages.yaml
#rm $STARTDIR/packages.tmp
cp $STARTDIR/upstreams.yaml  spack/etc/spack/defaults
echo Time to setup spack: $(mytime $now)



# Make sure we openmpi available
ml openmpi
ml
spack external find openmpi

# Here is the install

spack install hdf5 +mpi ^openmpi
#ml intel-oneapi-mpi
# the next install should actually be skipped if it finds it
#spack install intel-oneapi-mpi
#spack install hdf5 +mpi ^intel-oneapi-mpi

now=`mytime`
echo Time to install ior: $(mytime $now)


MODPATH=`find $MYDIR/modules -name hdf5`
MODPATH=`dirname $MODPATH`
echo Module path: $MODPATH

cd $STARTDIR

echo Total time: $(mytime $st)

