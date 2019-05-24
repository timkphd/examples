#include <stdlib.h>
#include <strings.h>
#include <string.h>
#include <mpi.h>
#include <math.h>
char *trim ( char *s );
int main(int argc, char **argv,char *envp[])
{
    char SLURM_JOB_ID[128],SLURM_ARRAY_JOB_ID[128],SLURM_ARRAY_TASK_ID[128];
    int myid,numprocs,k,resultlen;
    char lname[MPI_MAX_PROCESSOR_NAME] ;
    char *myname;
    myid=0;
    numprocs=0;
			MPI_Init(&argc,&argv);
			MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
			MPI_Comm_rank(MPI_COMM_WORLD,&myid);
	strcpy(SLURM_JOB_ID,"SLURM_JOB_ID");
	strcpy(SLURM_ARRAY_JOB_ID,"SLURM_ARRAY_JOB_ID");
	strcpy(SLURM_ARRAY_TASK_ID,"SLURM_ARRAY_TASK_ID");
	k=0;
	while(envp[k]) {
		if (strncmp(envp[k],"SLURM_JOB_ID",         strlen("SLURM_JOB_ID"))       == 0)
			strcpy(SLURM_JOB_ID        ,  envp[k]+(strlen("SLURM_JOB_ID")+1));
			
		if (strncmp(envp[k],"SLURM_ARRAY_JOB_ID",  strlen("SLURM_ARRAY_JOB_ID"))  == 0)
			strcpy(SLURM_ARRAY_JOB_ID  ,  envp[k]+(strlen("SLURM_ARRAY_JOB_ID")+1));
			
		if (strncmp(envp[k],"SLURM_ARRAY_TASK_ID", strlen("SLURM_ARRAY_TASK_ID")) == 0)
			strcpy(SLURM_ARRAY_TASK_ID ,  envp[k]+(strlen("SLURM_ARRAY_TASK_ID")+1));
			
		k++;
	}
	printf("%d %d %s %s %s\n",myid,numprocs,SLURM_JOB_ID,SLURM_ARRAY_JOB_ID,SLURM_ARRAY_TASK_ID);
	if (myid == 0) {
    MPI_Get_processor_name(lname,&resultlen); 
/* Get rid of "stuff" from the processor name. */
    myname=trim(lname);
/* The next line is required for BGQ because the MPI task ID 
 *    is encoded in the processor name and we don't want it. */
    if (strrchr(myname,32))myname=strrchr(myname,32);
	printf("running on %s\n",myname);
		for(k=0;k<argc;k++) {
			printf("command line argument %d = %s\n",k,argv[k]);
		}
	}
			MPI_Finalize();
}




char *trim ( char *s )
{
  int i = 0;
  int j = strlen ( s ) - 1;
  int k = 0;
 
  while ( isspace ( s[i] ) && s[i] != '\0' )
    i++;
 
  while ( isspace ( s[j] ) && j >= 0 )
    j--;
 
  while ( i <= j )
    s[k++] = s[i++];
 
  s[k] = '\0';
 
  return s;
}

