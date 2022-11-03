# Build with cmake and user defined package.yaml 
This script just builds a hybrid "hello world" application in OpenMP & MPI.  However, there are a few bells and whistles thrown in:

1. Uses *spack external find* to tell spack to use already installed versions of cmake and openmpi
1. Provides a example package.yaml that downloads a user defined *tgz file containing a CMakeLists.txt and source.
1. Shows how to install the package.yaml file. 
1. Shows how to do a build using cmake / make.  
1. Shows how to run a web browser to be a source for the install package.
1. Show how to use sha256sum to get the checksum of a downloaded file.


## Usage

```
.docmake.sh
```

The scripts also create two files, dirsettings and dospack.func.  Sourcing these two files and then running the function dospack will allow you to add applications to the spack instances.  For example:

```
source dirsettings
source dospack.func
dospack

spack install wget
```
