#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mpi.h"
#include <unistd.h>
#include <errno.h>
void split_it(int *argc, char ***argv, char **envp) {
/* start of additions for array jobs */
	extern int errno ;
	char SLURM_JOB_ID[128],SLURM_ARRAY_JOB_ID[128],SLURM_ARRAY_TASK_ID[128];
	static int did_call = 0;
	static int do_print = 0;
	char FLIST[128],DIR[1024],CWD[1024],DOPRINT[128];
	char lname[MPI_MAX_PROCESSOR_NAME] ;
	FILE *afile;
	int myid,numprocs,k,k2,resultlen,rc,myerr;
	if(did_call > 0){
		MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
		MPI_Comm_rank(MPI_COMM_WORLD,&myid);
		if(do_print == 3) printf("%d of %d done\n",myid,numprocs);
		fflush(stdout);
		MPI_Finalize();
		return;
	}
	did_call=100;
	myid=0;
	numprocs=0;
	MPI_Init(argc,argv);
	MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD,&myid);
	MPI_Get_processor_name(lname,&resultlen); 
	strcpy(SLURM_JOB_ID,"0");
	strcpy(SLURM_ARRAY_JOB_ID,"0");
	strcpy(SLURM_ARRAY_TASK_ID,"0");
	strcpy(FLIST,"");
	strcpy(DOPRINT,"yes");
	k=0;
	while(envp[k]) {
		if (strncmp(envp[k],"SLURM_JOB_ID",         strlen("SLURM_JOB_ID"))       == 0)
			strcpy(SLURM_JOB_ID        ,  envp[k]+(strlen("SLURM_JOB_ID")+1));
			
		if (strncmp(envp[k],"SLURM_ARRAY_JOB_ID",  strlen("SLURM_ARRAY_JOB_ID"))  == 0)
			strcpy(SLURM_ARRAY_JOB_ID  ,  envp[k]+(strlen("SLURM_ARRAY_JOB_ID")+1));
			
		if (strncmp(envp[k],"SLURM_ARRAY_TASK_ID", strlen("SLURM_ARRAY_TASK_ID")) == 0)
			strcpy(SLURM_ARRAY_TASK_ID ,  envp[k]+(strlen("SLURM_ARRAY_TASK_ID")+1));
			
		if (strncmp(envp[k],"FLIST", strlen("FLIST")) == 0)
			strcpy(FLIST ,  envp[k]+(strlen("FLIST")+1));
			
		if (strncmp(envp[k],"DOPRINT", strlen("DOPRINT")) == 0)
			strcpy(DOPRINT ,  envp[k]+(strlen("DOPRINT")+1));
			
		k++;
	}
	if (strlen("FLIST") > 1) {
		if ( (strncmp(DOPRINT,"yes", 3) == 0) || (strncmp(DOPRINT,"YES", 3) == 0) )
			do_print=3;
		k=myid+atoi(SLURM_ARRAY_TASK_ID);
		afile=fopen(FLIST,"r");
		for(k2=1;k2<=k;k2++) {
			fgets(DIR, sizeof(DIR), afile);
		}
		fclose(afile);
		getcwd(CWD,1024);
		if(do_print == 3) {
			printf("%d %d %s %s %s\n",myid,numprocs,SLURM_JOB_ID,SLURM_ARRAY_JOB_ID,SLURM_ARRAY_TASK_ID);
			printf("%d %s\n",myid,FLIST);
			printf("starting form %s\n",CWD);
			fflush(stdout);
		}
		DIR[strlen(DIR)-1]=(char)0; 
		//get rid of the end of line
		k=strlen(DIR);
		for(k2=0;k2<k;k2++)
			if(((int)DIR[k2])<21)DIR[k2]=(char)0;
		rc=chdir((const char *)&DIR[0]);
		if(rc != 0) {
        		myerr = errno;
			fprintf( stderr, "Task %d could not cd to directory %s ABORTING. Error:%s\n",myid,DIR,strerror(myerr));
			MPI_Abort(MPI_COMM_WORLD,myerr);
		}
		getcwd(CWD,1024);
		if(do_print == 3) {
			printf("%d Running %s %s %d\n",myid,lname,DIR,strlen(DIR));
			printf("now in %s %d\n",CWD,rc);
			fflush(stdout);
		}
  }      
/* end of additions for array jobs */
}

/* Note addition of             char **envp to "main" */
int main(int argc, char **argv, char **envp)
{

	//first call starts MPI and puts you in a directory
	split_it(&argc, &argv, envp);

	printf("// Your stuff goes here\n");	

	//second call stops MPI
	split_it(&argc, &argv, envp);

 		
 return 0;
}

/********   USAGE 

[tkaiser@mc2 raspa]$ mpixlc_r dummy.c -o dummy

[tkaiser@mc2 raspa]$ cat array2
#!/bin/bash -e
#SBATCH --job-name="array_job"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --time=48:00:00
#SBATCH -o outz-%j
##SBATCH --exclusive
#SBATCH --share
#SBATCH --export=ALL
##SBATCH --mem=1000

#----------------------
# example invocation
# Note that the array step size is equal to ntasks-per-node
# sbatch --array=1-18:2 array2

cd $SLURM_SUBMIT_DIR

if [[ $SLURM_ARRAY_JOB_ID ]] ; then
	JOB_ID=$SLURM_ARRAY_JOB_ID
	SUB_ID=$SLURM_ARRAY_TASK_ID
else
	JOB_ID=$SLURM_JOB_ID
	SUB_ID=0
fi

export FLIST=/u/pa/ru/tkaiser/asubdir/raspa/list
export DOPRINT=yes
#export DOPRINT=no

srun -n 2 ./dummy
wait

[tkaiser@mc2 raspa]$ cat list
180k3300kpa
180k3350kpa
180k3370kpa
180k3390kpa
180k3410kpa
180k3430kpa
183k3530kpa
183k3560kpa
183k3590kpa
183k3600kpa
183k3700kpa
183k3750kpa
185k3750kpa
185k3800kpa
185k3850kpa
185k3900kpa
185k3950kpa
185k4000kpa
[tkaiser@mc2 raspa]$ 

********/



