



Slurm Array Jobs
 pre { color: blue; font-size: 9pt; font-family: monospace; } p.s { width: 6in; text-align: justify; margin: .25in; } 




Slurm Array Jobs


Additional information can be found on the last slide of 
the presentation

http://geco.mines.edu/scripts



Array jobs offer a mechanism for submitting and managing
collections of similar jobs quickly and easily. All jobs
must have the same initial options (e.g. size, time limit,
etc.), however it is possible to change some of these
options after the job has begun execution using the command
specifying the JobID of the array or individual ArrayJobID. 


To submit a array of jobs you add the --array option to your
sbatch command.  For example


# Submit a job array with index values between 0 and 31
$ sbatch --array=0-31    -N1 tmp
# Submit a job array with index values of 1, 3, 5 and 7
$ sbatch --array=1,3,5,7 -N1 tmp
# Submit a job array with index values between 1 and 7
# with a step size of 2 (i.e. 1, 3, 5 and 7)
$ sbatch --array=1-7:2   -N1 tmp


Array jobs will have additional environment variables set. 


SLURM_ARRAY_JOB_ID 
		will be set to the first job ID of the array. 
		
SLURM_ARRAY_TASK_ID 
		will be set to the job array index value. 
		
SLURM_ARRAY_TASK_MAX 
		will be set to the maximum array index value. 
		
SLURM_ARRAY_TASK_MIN 
		will be set to the minimum array index value. 
		


For example a job submission of this sort:


sbatch --array=1-3 -N1 some_script 


will generate a job array containing three jobs. 


The sbatch command responds will respond with the batch job
id, say 361234. Then three copies of the job will be run
with the environment variables will set as follows: 


SLURM_ARRAY_JOB_ID=361234 
SLURM_ARRAY_TASK_MIN=1
SLURM_ARRAY_TASK_MAX=3
SLURM_JOBID=361234 
SLURM_ARRAY_TASK_ID=1 
 
SLURM_ARRAY_JOB_ID=361234 
SLURM_ARRAY_TASK_MIN=1
SLURM_ARRAY_TASK_MAX=3
SLURM_JOBID=361235 
SLURM_ARRAY_TASK_ID=2 
 
SLURM_ARRAY_JOB_ID=361234 
SLURM_ARRAY_TASK_MIN=1
SLURM_ARRAY_TASK_MAX=3
SLURM_JOBID=361236 
SLURM_ARRAY_TASK_ID=3


Each instance in the array gets defined a successive values
for SLURM_ARRAY_TASK_ID starting at 1. They also each get
successive values for SLURM JOB ID starting at
SLURM_ARRAY_JOB_ID. SLURM_ARRAY_JOB_ID is the same for all
of the instances in the array job. 


These environmental variables can be used to specify
different data sets for each run.  For example you might
have a file that lists a subdirectory or other parameters
for a run.  You can then use SLURM_ARRAY_TASK_ID to pick a
line from the file.  A quick (most likely not intuitive) way
of doing this is in your script is with the sed command:


cmd=`echo $SLURM_ARRAY_TASK_ID"q;d"`
aline=`sed -e $cmd $SLURM_SUBMIT_DIR/pars`


This will "pick" line number $SLURM_ARRAY_TASK_ID from the
file $SLURM_SUBMIT_DIR/pars where $SLURM_SUBMIT_DIR is the
starting directory for your run.


The values on the line can then be used to create strings
for command line arguments or directory names.


For example, assume $SLURM_ARRAY_TASK_ID=18 the 18th line of
our file is:


1 100 86 83


and the following lines were in our script:


cmd=`echo $SLURM_ARRAY_TASK_ID"q;d"`
aline=`sed -e $cmd $SLURM_SUBMIT_DIR/pars`
cl=`echo $aline | awk '{print("-v x " $1 " -v y " $2 " -v z " $3)}'`
dir=`echo $aline | awk '{print($1"/"$2"/"$3)}'`
echo "Line "  $SLURM_ARRAY_TASK_ID " is " $aline
echo "cl=" $cl 
echo "dir=" $dir


We would get


Line  18  is  1 100 86 83
cl= -v x 1 -v y 100 -v z 86
dir= 1/100/86


The string $dir could be used to create a directory and the
string $cl could be used as input for a program.  


Our example MPI programs:


dummy.c


The program "dummy.c" requires that an environmental
variable FLIST be set before it is run.  FLIST is the name
of a file that contains a list of directories.  dummy.c
takes the $SLURM_ARRAY_TASK_ID line from this list.  It then
does a cd to that directory.  The rest of the program runs
in that directory.  The first call to split_it starts MPI
and puts you in the directory.  The second call to split_it
quits MPI.  You can modify the program to do your work in
between.  For example:


int main(int argc, char **argv, char **envp)
{
        //first call starts MPI and puts you in a directory
        split_it(&amp;argc, &amp;argv, envp);
        printf("// Your stuff goes here\n");
        //second call stops MPI
        split_it(&amp;argc, &amp;argv, envp);
 return 0;
}


c_array.c, f_array.f 90 and p_array


The MPI programs c_array.c, f_array.f 90 and p_array are C,
Fortran, and python are more or less versions of the same
program.  They simply start MPI and then read the
environmental variables SLURM_JOB_ID, SLURM_ARRAY_JOB_ID,
and SLURM_ARRAY_TASK_ID.  They also read the command line
arguments used to run the program.  The environmental
variables and the command line arguments are printed.  


The worker*.* programs are discussed in a presentation on
bag of task parallelism.  Email tkaiser@mines.edu for more
information.  spam.c shows how to write a C routine callable
from python.


To build the examples on Mio:


module purge
module load StdEnv
module load PrgEnv/python/gcc/2.7.11
make


Our scripts:


array


This script runs the *_array programs discussed in the
previous paragraph.  If first uses the $SLURM_ARRAY_TASK_ID
to create a directory name.  The directory is created and
entered.  Then the programs are run with
$SLURM_ARRAY_TASK_MAX $SLURM_ARRAY_TASK_MIN passed in as
command line arguments.


array2


This script runs the dummy.c program.  Recall that this
program reads the environmental variable FLIST which is set
in the script.  FLIST is the name of a file that contains a
list of directories.  dummy.c takes the $SLURM_ARRAY_TASK_ID
line from this list.  It then does a cd to that directory. 
The rest of the program runs in that directory.  


array4


This script runs p_array.  First it creates a base directory
using the environmental variable $SLURM_ARRAY_JOB_ID and
enters the directory.  Next it uses the environmental
variable $SLURM_ARRAY_TASK_ID to select a line from the file
$SLURM_SUBMIT_DIR/pars as discussed above.  It them creates
a directory based on the values on the given line and runs
the program in that directory.  


This script contains some examples, as comments, on how you
might create a "pars" file.


If we used the command:


for a in `seq 0 2 10` ; do 
  for b in `seq 1 8 20` ; do 
    for c in `seq 5 5 10` ; do 
      echo $a $b $c >> pars
    done
  done
done


the pars file would contain 36 lines.  We could run the
script as follows


[tkaiser@mio001 bot]$ !sbatch
sbatch --array=1-36 array4
Submitted batch job 3492514


This would give us the directory structure and output files:


3492514/0/1/10/out.dat
3492514/0/1/5/out.dat
3492514/0/9/10/out.dat
3492514/0/9/5/out.dat
3492514/0/17/5/out.dat
3492514/0/17/10/out.dat
3492514/2/1/5/out.dat
3492514/2/1/10/out.dat
3492514/2/9/5/out.dat
3492514/2/9/10/out.dat
3492514/2/17/5/out.dat
3492514/2/17/10/out.dat
3492514/4/1/5/out.dat
3492514/4/1/10/out.dat
3492514/4/9/5/out.dat
3492514/4/9/10/out.dat
3492514/4/17/5/out.dat
3492514/4/17/10/out.dat
3492514/6/1/5/out.dat
3492514/6/1/10/out.dat
3492514/6/17/5/out.dat
3492514/6/17/10/out.dat
3492514/6/9/5/out.dat
3492514/6/9/10/out.dat
3492514/8/1/5/out.dat
3492514/8/1/10/out.dat
3492514/8/9/5/out.dat
3492514/8/9/10/out.dat
3492514/8/17/5/out.dat
3492514/8/17/10/out.dat
3492514/10/1/5/out.dat
3492514/10/1/10/out.dat
3492514/10/17/5/out.dat
3492514/10/17/10/out.dat
3492514/10/9/5/out.dat
3492514/10/9/10/out.dat



