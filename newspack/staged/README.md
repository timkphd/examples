# Multi Stage install
Creates a spack hierarchy *level00* and *level01* with level01 reusing "stuff" installed in *level00*. That is, in spack terminology level00 is upstream of level01.

In particular the first script, **spell.sh**, creates an environment and then installs aspell, a spell check program.  It also creates a file upstream.yaml that describes the layout of the install and modules directories.  

The second script, **dict.sh** is very similar to the first except it creates its distribution in level01 instead of level00.  It also copies the upstream.yaml file to its setting directory.  Finally it installs a dictionary for aspell.  If the upstream.yaml file was not present then spack would also install aspell because it is a dependency for the dictionary.  

The second script also prints out the module paths for the programs modules.


## Usage

```
./spell.sh
./dict.sh
```

The scripts also create two files dirsettings and dospack.func.  Sourcing these two files and then running the function dospack will allow you to add applications to the spack instances.  For example:

```
source dirsettings
source dospack.func
dospack

spack install wget
```
