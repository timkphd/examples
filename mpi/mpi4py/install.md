<style type="text/css" rel="stylesheet">
body {
  font-family: Helvetica, arial, sans-serif;
  font-size: 14px;
  line-height: 1.6;
  padding-top: 10px;
  padding-bottom: 10px;
  background-color: white;
  padding: 30px;
  color: #333;
}
pre { color: #f000ff;background-color: #f0f0f0;font-size: 12px}
strong {white-space: pre;color: #0000ff;font-size: 14px;font-family:monospace}

</style>

# Create a conda environment for mpi4py using Intel MPI


### Make a backup of your .bashrc file and save the lines that create a conda environment
```
now=`date +"%y%m%d%H%M"`
echo $now
cd ~
# backkup of .bashrc
cp .bashrc bashrc.$now

# create a file that has your old conda setting
sed -n '/conda initialize/,/conda initialize/p' .bashrc > conda.$now

#  remove your old conda setting from .bashrc
sed -i.$now '/conda initialize/,/conda initialize/d' .bashrc
```

### You can see your backups


```
ls -al | grep $now
```

This should return something like:
<strong>
-rw- - - - - - -.    1 tkaiser2 tkaiser2      3845 Aug  5 14:00 .bashrc.2008051421
-rw- - - - - - -.    1 tkaiser2 tkaiser2      3845 Aug  5 14:21 bashrc.2008051421
-rw-rw - - - - -.    1 tkaiser2 tkaiser2       512 Aug  5 14:21 conda.2008051421
</strong>

### logout/in

## Create a new environment, mpi4pi0805

You'll need to answer yes to the question posed by the conda create command.  
```
module use /nopt/nrel/apps/modules/centos77/modulefiles/
module purge
ml conda/2020.07
ml intel-mpi/2020.1.217
ml mkl/2020.1.217

conda create --name mpi4pi0805 python=3.7 jupyter matplotlib scipy pandas 

conda init bash
```

### logout/in

## Install mpi4py

```
module use /nopt/nrel/apps/modules/centos77/modulefiles/
module purge
ml conda/2020.07
ml intel-mpi/2020.1.217
ml mkl/2020.1.217
conda activate mpi4pi0805

pip install mpi4py
```

## Test mpi4py

You can download the example below:

```
git clone https://github.com/timkphd/examples
```


In the text below you will need "cd" to the directory contining the file report.py and replace "hpcapps" with a valid account number.  Note that we use srun to get our interactive session and to start the application, not mpirun.

```
cd ~/examples/mpi/mpi4py
srun  --x11 --account=hpcapps --time=1:00:00 --partition=debug --ntasks=8 --nodes=1 --pty bash

module use /nopt/nrel/apps/modules/centos77/modulefiles/
module purge
ml conda/2020.07
ml intel-mpi/2020.1.217
ml mkl/2020.1.217
conda activate mpi4pi0805

srun   -n 8 ./report.py | sort
```

This should return something like:
<strong>
Running MPI libary  Intel(R) MPI Library 2019 Update 7 for Linux* OS
Tasks:  8  MPI Version  (3.1)
xxxxxx Hello from  0  on  r7i7n35
xxxxxx Hello from  1  on  r7i7n35
xxxxxx Hello from  2  on  r7i7n35
xxxxxx Hello from  3  on  r7i7n35
xxxxxx Hello from  4  on  r7i7n35
xxxxxx Hello from  5  on  r7i7n35
xxxxxx Hello from  6  on  r7i7n35
xxxxxx Hello from  7  on  r7i7n35
</strong>
