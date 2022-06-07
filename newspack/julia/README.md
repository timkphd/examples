# Julia
Creates a Julia  environment.  It also creates a python environment with Jupyter-lab and other tools.  Instructions are given on how to enable Julia in jupyter-lab.


## Usage

Edit the file dojules.sh and change the line

```export MYDIR=/nopt/nrel/apps/210929a/level03```

to point to where you want your software to be installed.  

Then

```sbatch --partition=short --account=hpcapps dojules.sh```

changing *short* and *hpcapps* as needed.


The pip installs are:

```
pip3 install matplotlib
pip3 install pandas
pip3 install scipy
pip3 install jupyterlab
#pip3 install reframe-hpc
#pip3 install pygelf
```

If you want to install reframe uncomment the last two lines.


To change the version installed find the url for the new version and change it in the julia.py file along with updating version string and the sha256 key.
