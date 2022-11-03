# Openfoam
Creates a Openfoam  environment.  

## Usage

Edit the file dofoam.sh and change the line

```export MYDIR=/lustre/eaglefs/scratch/tkaiser2/openfoam/build3```

to point to where you want your software to be installed.  Don't put Openfoam in you home directory.  It most likely will not fit.

Then

```sbatch  --account=hpcapps dofoam.sh```

changing *hpcapps* as needed.


The job will run for about 2 hours after which you should have a new build of Openfoam, and modules that you can use to point to it.


At the end of the output from the job *opnfm_build* ou will have the *module use* lines required to point to the new modules.  Copy/Paste these
lines to your treminal.  You may want to add them to your .bashrc file.  

Also, there will be a note that you will need to edit some of the module files to remove a dependency for openmpi.  Openmpi is actually
required but the line in the module will not point to the correct version. You should load it manually as described in the output file 
or edit the line to point to *openmpi/4.1.1/gcc+cuda*.


If you want to change the version of Openfoam installed edit the line 

```
spack install openfoam
```

in dofoam.sh.  


Here are the versions available via spack as of 04/18/22.  2112 is the default and the others have not been tested.  
 
```
2112
2106_211215
2106
2012_210414
2012
2006_201012
2006
1912_200506
1912_200403
1912
1906_200312
1906_191103
1906
1812_200312
1812_191001
1812_190531
1812
1806
1712
1706
1612
``` 
You select the version on the on the s*pack install openfoam* line like this:
 
 
```
spack install openfoam@2106

```
 
I believe you can have multiple versions get installed and they will not conflict.  
 
```
spack install openfoam@2106
spack install openfoam@2112
```

Again, this has not been tested.
 
 
There are options you can specify.
 
```
float32         Use single-precision
spdp            Use single/double mixed precision
int64           With 64-bit labels
knl             Use KNL compiler settings
kahip           With kahip decomposition
metis           With metis decomposition
zoltan          With zoltan renumbering
mgridgen        With mgridgen support
paraview        Build paraview plugins and runtime post-processing
vtk             With VTK runTimePostProcessing
```

These would be selected like this:
 
spack install openfoam +spdp


This script should work on other platforms if you edit dofoam.sh to point to the correct modules **and** edit the file packages.yaml to point to the full path of the directory containing openmpi.

