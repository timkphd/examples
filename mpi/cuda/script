#!/bin/bash
#SBATCH --job-name="gpumpi"
#SBATCH --nodes=2
#SBATCH --partition=gpu
#SBATCH --gres=gpu:4
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=00:20:00
#SBATCH -o summary.%j

. /nopt/nrel/apps/env.sh
ml nvhpc
export LD_LIBRARY_PATH=/nopt/nrel/apps/compilers/02-23/spack/opt/spack/linux-rocky8-zen2/gcc-10.1.0/nvhpc-23.9-z37vdi3iyrnjnm7r4cqgr774vm6brvrp/Linux_x86_64/23.9/REDIST/cuda/12.2/targets/x86_64-linux/lib:$LD_LIBRARY_PATH 

mytime ()
{
    now=`date +"%s.%N"`
    if (( $# > 0 )); then
	    rtn=`python -c "print('%8.3f' %  ($now - $1))"`
    else
       rtn=`python -c "print('%8.3f' %  ($now))"`
    fi
    echo $rtn
}

rm -f */*off */*on
rm -f *off *on

cd cpu
make clean ; echo
make 2>/dev/null ; echo
echo cpu_off ;start=`mytime`
mpirun -N 1 ./pp | tee cpu_off
echo DT= `mytime $start ` 
echo cpu_on ;start=`mytime`
mpirun -n 2 ./pp | tee cpu_on
echo DT= `mytime $start ` 
make clean ; echo
cd ..

cd cuda_staged
make clean ; echo
make 2>/dev/null ; echo
echo staged_off ;start=`mytime`
mpirun -N 1 pp_cuda_staged | tee staged_off
echo DT= `mytime $start ` 
echo staged_on ;start=`mytime`
mpirun -n 2 pp_cuda_staged | tee staged_on
echo DT= `mytime $start ` 
make clean ; echo
cd ..

cd cuda_aware
make clean ; echo
make 2>/dev/null ; echo
echo aware_off ;start=`mytime`
mpirun -N 1 pp_cuda_aware | tee aware_off
echo DT= `mytime $start ` 
echo aware_on ;start=`mytime`
mpirun -n 2 pp_cuda_aware | tee aware_on
echo DT= `mytime $start ` 
make clean ; echo
cd ..

echo done

cat cpu/cpu_off            | awk '{print $4,$11}' | sed "s/,//" > cpu_off
cat cpu/cpu_on             | awk '{print $4,$11}' | sed "s/,//" > cpu_on

cat cuda_staged/staged_off | awk '{print $4,$11}' | sed "s/,//" > staged_off
cat cuda_staged/staged_on  | awk '{print $4,$11}' | sed "s/,//" > staged_on 

cat cuda_aware/aware_off   | awk '{print $4,$11}' | sed "s/,//" > aware_off
cat cuda_aware/aware_on    | awk '{print $4,$11}' | sed "s/,//" > aware_on

#rm -f */*off */*on
#rm -f *off *on
#rm -f summary.*

