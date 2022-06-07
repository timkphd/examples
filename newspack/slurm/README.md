# Slurm build

Builds slurm using the system installed version of munge.  It creates a packages.yaml file that points to a number of preinstalled packages.


It also creates a file upstream.yaml that describes the layout of the install and modules directories.  This can be used to create a hierarchy of spack builds.  See ../staged.


## Usage

Edit the slurm.sh file. In particular change the prefix lines in the section that creates the packages.tmp file to point to any packages you want to use.  You don't need to edit the munge section it will get fixed automatically.  


```
./slurm.sh
```

The scripts also create two files dirsettings and dospack.func.  Sourcing these two files and then running the function dospack will allow you to add applications to the spack instances.  For example:

```
source dirsettings
source dospack.func
dospack

spack install wget
```
