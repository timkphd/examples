##### must be run from a subdirectory "start"
##### lest it try to run all *.py files
%load_ext slurm_magic

from slideshow import mysay
from tymer import tymer
from tymer import clist
from tymer import sprint

mpi4py=mysay(datadir="mpi01_py")

mpi4py.nx()

%macro n 4

cd ../..

srun -n 8 hostname

!srun -n 8 hostname

tymer(["-i","start"])

%%capture out
srun -n 8 ./report.py

tymer(["-i","done"])

for x in clist(out) :
    print(x)

mpi4py.nx(0)

n
