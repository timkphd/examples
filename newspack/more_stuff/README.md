# Build R and add packages 

This script just builds "R".  Running 

```
Rscript rstall.R 

```


## Usage

Edit the file to change the export MYDIR=... line.


```
sbatch domore.sh
```

You can then add typical datad analysis packages to R.

Find the installed "Rscript and use it to run the script rstall.R 

```
/full/path/to/Rscript rstall.R
```

Or you can just run rstall.R against a previously build version of R.

The scripts also create two files, dirsettings and dospack.func.  Sourcing these two files and then running the function dospack will allow you to add applications to the spack instances.  For example:

```
source dirsettings
source dospack.func
dospack

spack install wget
```
