# spack
### spack scripts

Below you can see a one line description of what the various scripts do.  However, each has unique features showing how to do various things in spack.  I recomend that you read all of the complere descriptons.

These worked when posted to the repositiory.  However systems change and spack changes.  You'll most likely need to make edits.

## boot/README.md
Creates a gcc and python environment to be used to build more environments.

## docmake/README.md
Build with cmake and user defined package.yaml 

## julia/README.md
Creates a Julia  environment.  It also creates a python environment with Jupyter-lab and other tools.  Instructions are given on how to enable Julia in jupyter-lab.

## more_stuff/README.md
Build R and add packages 

## openfoam/README.md
Creates a Openfoam  environment.  

## staged/README.md
Multi Stage install

## system/README.md
Build HPC software stacks

## ior/README.md
Builds ior with IntelMPI and OpenMPI



If after "using" new modules you get a  stack overflow when doing a module avail check the modules for
recursion.  For example:

```
[tkaiser2@el1 ~]$ module use /nopt/nrel/apps/220511a/modules/lmod/linux-centos7-x86_64/gcc/12.1.0
[tkaiser2@el1 ~]$ module avail

/nopt/nrel/utils/lua/5.1.4.5/bin/lua: /nopt/nrel/utils/lmod/lmod/libexec/Spider.lua:468: stack overflow
stack traceback:
	/nopt/nrel/utils/lmod/lmod/libexec/Spider.lua:468: in function 'l_search_mpathParentT'
...
...
[tkaiser2@el1 ~]$

[tkaiser2@el2 12.1.0]$ cd/nopt/nrel/apps/220511a/modules/lmod/linux-centos7-x86_64/gcc/12.1.0

[tkaiser2@el2 12.1.0]$ grep prepend_path */* | grep MODULEPATH
gcc/12.1.0-wtsh7ja.lua:prepend_path("MODULEPATH", "/nopt/nrel/apps/220511a/modules/lmod/linux-centos7-x86_64/gcc/12.1.0")
intel-oneapi-mpi/2021.6.0-c74x2fc.lua:prepend_path("MODULEPATH", "/nopt/nrel/apps/220511a/modules/lmod/linux-centos7-x86_64/intel-oneapi-mpi/2021.6.0-c74x2fc/gcc/12.1.0")
nvhpc/22.3-c4qk6fl.lua:prepend_path("MODULEPATH", "/nopt/nrel/apps/220511a/modules/lmod/linux-centos7-x86_64/nvhpc/22.3")
nvhpc/22.3-c4qk6fl.lua:prepend_path("MODULEPATH", "/nopt/nrel/apps/220511a/modules/lmod/linux-centos7-x86_64/nvhpc/22.3-c4qk6fl")
nvhpc/22.3-c4qk6fl.lua:prepend_path("MODULEPATH", "/nopt/nrel/apps/220511a/modules/lmod/linux-centos7-x86_64/nvhpc/22.3-c4qk6fl/nvhpc/22.3")
[tkaiser2@el2 12.1.0]$ vi gcc/12.1.0-wtsh7ja.lua

```

Note the gcc module reloads the module path.  Comment out this line.


