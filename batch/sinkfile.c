#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mpi.h>
#include <math.h>
void sinkfile_(double *dt, int *gt, int *theid, char *afile, char *bfile,int dummy);
 
/************************************************************
This is a simple hello world program. Each processor prints out
it's rank and the size of the current MPI run (Total number of
processors).

Then the complicated part.  We use MPI_Bcast to create copies
of a file "segment" one per node, not one per task. We assume
that the MPI tasks are running in a directory that is not shared
across all tasks but can be seen by all tasks on a node, that
is local to a node.

Note: We assume that the file "segment" exists on the local
disk of MPI task 0.

The Fortran call of this routine would be: 

call sinkfile(dt,"segment")

The size is a hidden value passed in by Fortran.

Compile for "real" usage:
mpicc -c sinkfile.c

Compile for test usage. We create a unique file name for each 
copy. Thus this will work on a shared file system:
mpicc -DDO_LOCAL_FILE_TEST -c sinkfile.c

Compile for test usage with the C main program
mpicc -DDO_LOCAL_FILE_TEST -DDO_C_TEST sinkfile.c -o sinkfile

command to generate an example file
od -vAn -d -N1048576 < /dev/urandom > segment

************************************************************/
#ifdef DO_C_TEST
int main(int argc, char **argv,char *envp[])
{
    int myid, numprocs;
    FILE *f1;
    int i;
    double the_time;
    int id_sink,i_got,resultlen;
    char myname[MPI_MAX_PROCESSOR_NAME];
    char src[128],dest[128];
 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name( myname,&resultlen );
    
    if (myid == 0 ) {
		if (argc > 1)
			strcpy(src,argv[1]);
		else
			strcpy(src,"source");
		if (argc > 2)
			strcpy(dest,argv[2]);
		else
			strcpy(dest,"dest");
    }
    	
    	
    MPI_Bcast( src,128,MPI_CHAR,0,MPI_COMM_WORLD);
    MPI_Bcast(dest,128,MPI_CHAR,0,MPI_COMM_WORLD);


    printf("Hello from %d of %d on %s %s %s \n",myid,numprocs,myname,src,dest);
    sinkfile_(&the_time, &i_got, &id_sink,src,dest,0);

    
	printf(" for proc %d time= %g for %d bytes\n",id_sink,the_time,i_got);
    MPI_Finalize();
   
}
#endif
/****************************************/
void sinkfile_(double *dt, int *gt, int *theid, char *afile, char *bfile,int dummy) {
#include <mpi.h>
#include <string.h>
#include <unistd.h>
char *alist,*tname;
char **blist;
int numprocs,i,j,unique,onlist,myid;
int resultlen,start;
int *lenlist,*include;
char myname[MPI_MAX_PROCESSOR_NAME];
int mpi_root;
int *proclist;
int used_id;
double t1;
MPI_Comm SINK_COMM_WORLD;
MPI_Group new_group,old_group;
char *buffer;
size_t buffer_size;
int got;
char fname[256];
char bonk[16];
FILE *infile,*outfile;

mpi_root=0;
buffer_size=1024*1024;
*gt=0;
t1=MPI_Wtime();
MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
MPI_Comm_rank(MPI_COMM_WORLD,&myid);
MPI_Get_processor_name( myname,&resultlen );
*theid=myid;

//printf("%d %s\n",myid,myname);
if(myid == mpi_root) {
	alist=(char*)malloc(numprocs*(MPI_MAX_PROCESSOR_NAME)*sizeof(char));
	include=(int*)malloc(numprocs*sizeof(int));
}

          MPI_Gather(myname,MPI_MAX_PROCESSOR_NAME,  MPI_CHAR, 
					 alist, MPI_MAX_PROCESSOR_NAME,  MPI_CHAR, 
	                 	mpi_root,                  
	                 	MPI_COMM_WORLD);

if(myid == mpi_root) {
		blist=(char**)malloc(numprocs*sizeof(char*));
		blist[0]=(char*)malloc(MPI_MAX_PROCESSOR_NAME*sizeof(char));
		strncpy(blist[0],alist,(size_t)MPI_MAX_PROCESSOR_NAME);
		include[0]=mpi_root;
		unique=1;
		start=0;
		/* printf("starting with %s %d\n",blist[0],include[0]); */
		for (i=1;i<numprocs;i++) {
			onlist=0;
			start=start+MPI_MAX_PROCESSOR_NAME;
			tname=alist+start;
			for (j=0;j<unique;j++) {
				if( strcmp(tname,blist[j]) == 0 ) {
					onlist=1;
					/* printf("%s %s %d\n",tname,blist[j],onlist); */
				}
			}
			if( onlist == 0){
				/* printf("adding %s %d\n",tname,i); */
				blist[unique]=(char*)malloc(MPI_MAX_PROCESSOR_NAME*sizeof(char));
				strcpy(blist[unique],tname);
				include[unique]=i;
				unique++;
			}
		}
		/* printf("Final list:\n"); */
		for (j=0;j<unique;j++) {
			/* printf("%d %s\n",include[j],blist[j]); */
			free(blist[j]);
		}
		free(blist);
		free(alist);
	}
	MPI_Bcast(&unique,1,MPI_INT,mpi_root,MPI_COMM_WORLD);
	*dt=MPI_Wtime()-t1;
	if (unique < 2) return;
	proclist=(int*)malloc(unique*sizeof(int));
	if(myid == mpi_root) {
		for (j=0;j<unique;j++) {
			proclist[j]=include[j];
		}
		free(include);
	} 
	MPI_Bcast(proclist,unique,MPI_INT,mpi_root,MPI_COMM_WORLD);
	MPI_Comm_group(MPI_COMM_WORLD,&old_group);
	MPI_Group_incl(old_group,unique,proclist,&new_group);
	free(proclist);
	MPI_Comm_create(MPI_COMM_WORLD,new_group,&SINK_COMM_WORLD);
	MPI_Group_rank(new_group,&used_id);
	if(used_id == MPI_UNDEFINED){
/* if not part of the new group wait then clean up and return */
		/* printf("not included %d\n",myid); */
		MPI_Barrier(MPI_COMM_WORLD);
/*
		MPI_Comm_free(&SINK_COMM_WORLD);
*/
		MPI_Group_free(&new_group);
		*dt=MPI_Wtime()-t1;
		return;
	}
/* if part of the new copy the file */
	MPI_Comm_rank(SINK_COMM_WORLD,&used_id);
	//printf("included %d %d\n",myid,used_id);

	if( myid == mpi_root) {
		if (used_id != mpi_root) {
			printf("ids don't match %d %d\n",used_id,myid);
			MPI_Abort(MPI_COMM_WORLD,12345);
		}
	}
/* allocate the buffer */
	buffer=(char*)malloc(buffer_size*sizeof(char));
/* root  */
	if(used_id == mpi_root) {
		if (dummy > 0) {
			strncpy(fname,afile,dummy);
			fname[dummy]=(char)0;
		}
		else {
			strcpy(fname,afile);
		}
		// printf("210 %d %d %s\n",myid,used_id,bfile);
		MPI_Bcast(bfile,128,MPI_CHAR,mpi_root,SINK_COMM_WORLD);
		// printf("210b %d %d\n",myid,used_id);
/*     opens for read */
		infile=fopen(afile,"r");
		printf("open for write %s from %d\n",bfile,myid);
		outfile=fopen(bfile,"w");
/*     reads upto buffer char */
		got=fread(buffer,1,buffer_size,infile);
		fwrite(buffer,1,got,outfile);
		   
		*gt=*gt+got;
/*     bcast number read */
		// printf("222 %d %d\n",myid,used_id);
		MPI_Bcast(&got,1,MPI_INT,mpi_root,SINK_COMM_WORLD);
		while(got > 0){
/*     bcast buffer */
			MPI_Bcast(buffer,got,MPI_CHAR,mpi_root,SINK_COMM_WORLD);
			got=fread(buffer,1,buffer_size,infile);
			fwrite(buffer,1,got,outfile);
			*gt=*gt+got;
			MPI_Bcast(&got,1,MPI_INT,mpi_root,SINK_COMM_WORLD);
			
		}
		fclose(infile);
	}
	else {
/* other  */
		// printf("237 %d %d %s\n",myid,used_id,bfile);
		MPI_Bcast(bfile,128,MPI_CHAR,mpi_root,SINK_COMM_WORLD);
		// printf("237b %d %d\n",myid,used_id);

/* next two lines are for testing only in a shared file system */
#ifdef DO_LOCAL_FILE_TEST
		 sprintf(bonk,"%5.5d",used_id);
		 strcat(bfile,bonk); 
#endif
/*     opens for write */
		printf("open for write %s from %d\n",bfile,myid);
		outfile=fopen(bfile,"w");
/*     get bcast number read */
		// printf("248 %d %d\n",myid,used_id);
		MPI_Bcast(&got,1,MPI_INT,mpi_root,SINK_COMM_WORLD);
		while( got > 0 ){
/*     get bcast buffer */
		// printf("252 %d %d\n",myid,used_id);
			MPI_Bcast(buffer,got,MPI_CHAR,mpi_root,SINK_COMM_WORLD);
/*     writes buffer */
			fwrite(buffer,1,got,outfile);
			*gt=*gt+got;
		// printf("257 %d %d\n",myid,used_id);
			MPI_Bcast(&got,1,MPI_INT,mpi_root,SINK_COMM_WORLD);
		}
	}
	fclose(outfile);
/* close the file clean up and return*/
	free(buffer);
	MPI_Barrier(MPI_COMM_WORLD);
	MPI_Comm_free(&SINK_COMM_WORLD);
	MPI_Group_free(&new_group);
	*dt=MPI_Wtime()-t1;
}
