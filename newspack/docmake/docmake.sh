#!/bin/bash

###### IMPORTANT ######
# If the fhostone-1.0.tar.gz file changes in any way, even
# if it is just expanded and retarred the sha256sum command
# must be run and the returned string replacing the one in
# the package.py file.  See package.py for details.

module load python
python3 -m http.server &


# Check to see if we have a web server running
ps -u | grep http.server | grep python
if [[ $? == 0 ]] ; then
	echo "###########################################"
	echo web server is running 
	echo "###########################################"
else
	echo "###########################################"
	echo "start a web server with the command:"
	echo "python3 -m http.server &"
	echo "###########################################"
	exit
fi

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

ml
# Start spack
dospack


# Modify the config files to point to the install directory and to make lmod modules
backup=`date +"%y%m%d%H%M%S"`
sed -i$backup "s,root: \$spack,root: $MYDIR/install," spack/etc/spack/defaults/config.yaml
sed -i$backup "s,\$spack/share/spack,$MYDIR/modules," spack/etc/spack/defaults/modules.yaml
sed -ib "s/- tcl/- lmod/"                             spack/etc/spack/defaults/modules.yaml


echo Time to setup spack: $(mytime $now)


# Add our package to a local repo
if [[ ! -d myrepo ]];then
  spack repo create myrepo
  spack repo add myrepo
fi
mkdir -p myrepo/packages/fhostone
cp $STARTDIR/package.py  myrepo/packages/fhostone/package.py

# Make sure we cmake and openmpi available
ml cmake
ml openmpi
spack external find cmake
spack external find openmpi

# This is for an example only.  We are getting our tar ball 
# from a web server running locally.  The URL is specified
# in the package.py file as:
# http://127.0.0.1:8000/fhostone-1.0.tar.gz
# We test above to see if we have one running. 

# Also, this will fail if the webserver is not running
rm -rf index.html
wget http://127.0.0.1:8000


# Here is the install
spack install fhostone

# Kill the web server
kill `ps -u | grep http.server | grep python | awk '{print $2}'`

now=`mytime`
echo Time to install fhostone: $(mytime $now)


MODPATH=`find $MYDIR/modules -name fhostone`
MODPATH=`dirname $MODPATH`
echo Module path: $MODPATH

cd $STARTDIR

echo Total time: $(mytime $st)

