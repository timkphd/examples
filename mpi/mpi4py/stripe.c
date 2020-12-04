#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>
#include <math.h>
#include <unistd.h>
#include <sys/time.h>
#include <time.h>


#include "hdf5.h"

#define H5FILE_NAME     "parallel_test.hdf5"
#define DATASETNAME 	"IntArray" 




int main(int argc, char **argv,char *envp[])
{
    int i,rank, numprocs,k,iret,mb,resultlen,jid,sub;
    char myname[MPI_MAX_PROCESSOR_NAME] ;
    char SLURM_JOBID[32],SUB[32],size[32],count[32],mbin[32];
    char icommand[256],cwd[256],outline[256],xout[32];
    char fout[32];
    long ilong,j;
    double t[8],x;
    int *rdat;
    FILE  * file;
    struct timeval now;

#ifndef ENVP
// Intel MPI is broken w.r.t. to getting values from envp
// So ENVP must be set to argv and options put on the command 
// line.  For example
// srun -n 4 ./a.out  SLURM_JOBID=$SLURM_JOBID
#define ENVP envp
#endif
#pragma "reading from " ENVP
    
    
    hid_t       file_id, dset_id;         /* file and dataset identifiers */
    hid_t       filespace, memspace;      /* file and memory dataspace identifiers */
    hsize_t     dimsf[2];                 /* dataset dimensions */
    hsize_t	icount[2];	          /* hyperslab selection parameters */
    hsize_t	offset[2];
    hid_t	plist_id;                 /* property list identifier */
    herr_t	status;


    MPI_Comm comm  = MPI_COMM_WORLD;
    MPI_Info info  = MPI_INFO_NULL;

    MPI_Request request; 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Get_processor_name(myname,&resultlen);
    SUB[0]=(char)0;
    SLURM_JOBID[0]=(char)0;
    jid=0;
    sub=0;
    if (rank == 0) {
		k=0;
		jid=-1;
		sub=0;
		while(ENVP[k]) {
		    //printf("%s %d\n",ENVP[k],k);
			if (strncmp(ENVP[k],"SLURM_JOBID",         strlen("SLURM_JOBID"))       == 0) {
				strcpy(SLURM_JOBID        ,  ENVP[k]+(strlen("SLURM_JOBID")+1));
				sscanf(SLURM_JOBID,"%d",&jid);
				//printf("jid %d\n",jid);
				}
			
			if (strncmp(ENVP[k],"SUB",  strlen("SUB"))  == 0) {
				strcpy(SUB  ,  ENVP[k]+(strlen("SUB")+1));
				sscanf(SUB,"%d",&sub);
				//printf("sub %d\n",sub);
				}
			k++;
		}
    }
    //printf("did env\n");
//    MPI_Finalize();
//    exit(0);
	MPI_Bcast(&jid,1,MPI_INT,0,MPI_COMM_WORLD);
	MPI_Bcast(&sub,1,MPI_INT,0,MPI_COMM_WORLD);
	//printf("did bcast\n");
//    MPI_Finalize();
//    exit(0);
	
	
	strcpy(mbin,"128");
	if (rank == 0 ) {
    	strcpy(size,"64M");
    	strcpy(count,"-1");
    	k=0;
		for (k=0 ; k<argc;k++) {
		
        if (strncmp(argv[k],"-size",        strlen("-size"))       == 0)
				strcpy(size        ,  argv[k]+(strlen("-size")+1));
				
        if (strncmp(argv[k],"-mb",         strlen("-mb"))       == 0)
				strcpy(mbin        ,  argv[k]+(strlen("-mb")+1));
				
        if (strncmp(argv[k],"-count",         strlen("-count"))       == 0)
				strcpy(count        ,  argv[k]+(strlen("-count")+1));
		}
    getcwd(cwd, (size_t)(256));
    sprintf(icommand,"lfs setstripe -S %s -c %s %s",size,count,cwd);
    iret=system(icommand);
    printf("%s error code=%d file size %d M(ints)/task\n",icommand,iret,mb);
    sleep(5);
    sscanf(mbin,"%d",&mb);
	}
	MPI_Bcast(&mb,1,MPI_INT,0,MPI_COMM_WORLD);
	MPI_Barrier(MPI_COMM_WORLD);
        gettimeofday(&now,NULL);
	t[6]=(double)(now.tv_sec)+(double)(now.tv_usec)*1e-6;
	t[0]=MPI_Wtime();
	ilong=(long)(1024*1024)*(long)mb;
	//ilong=(long)(128*128)*(long)mb;
	rdat=(int*)malloc(ilong*sizeof(int));
	for (j=0;j<ilong;j++) {
		rdat[j]=rank;
	};
	
	t[1]=MPI_Wtime();
		//f = h5py.File('parallel_test.hdf5', 'w', driver='mpio', comm=MPI.COMM_WORLD)
    /* 
     * Set up file access property list with parallel I/O access
     */
     plist_id = H5Pcreate(H5P_FILE_ACCESS);
     H5Pset_fapl_mpio(plist_id, comm, info);

    /*
     * Create a new file collectively and release property list identifier.
     */
    file_id = H5Fcreate(H5FILE_NAME, H5F_ACC_TRUNC, H5P_DEFAULT, plist_id);
    H5Pclose(plist_id);


	t[2]=MPI_Wtime();
		//dset = f.create_dataset('test', (numprocs,ilong), dtype='i')
	/*
     * Create the dataspace for the dataset.
     */
    dimsf[0] = numprocs;
    dimsf[1] = ilong;
    filespace = H5Screate_simple(2, dimsf, NULL); 

    /*
     * Create the dataset with default properties and close filespace.
     */
    dset_id = H5Dcreate(file_id, DATASETNAME, H5T_NATIVE_INT, filespace,
			H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
    H5Sclose(filespace);

    /* 
     * Each process defines dataset in memory and writes it to the hyperslab
     * in the file.
     */
    icount[0] = dimsf[0]/numprocs;
    icount[1] = dimsf[1];
    offset[0] = rank * icount[0];
    offset[1] = 0;
    memspace = H5Screate_simple(2, icount, NULL);

    /*
     * Select hyperslab in the file.
     */
    filespace = H5Dget_space(dset_id);
    H5Sselect_hyperslab(filespace, H5S_SELECT_SET, offset, NULL, icount, NULL);
	t[3]=MPI_Wtime();
		//dset[rank] = rdat
	 /*
     * Select hyperslab in the file.
     */
    filespace = H5Dget_space(dset_id);
    H5Sselect_hyperslab(filespace, H5S_SELECT_SET, offset, NULL, icount, NULL);


    /*
     * Create property list for collective dataset write.
     */
    plist_id = H5Pcreate(H5P_DATASET_XFER);
    H5Pset_dxpl_mpio(plist_id, H5FD_MPIO_COLLECTIVE);
    
    status = H5Dwrite(dset_id, H5T_NATIVE_INT, memspace, filespace,
		      plist_id, rdat);
    //free(rdat);

	t[4]=MPI_Wtime();
    /*
     * Close/release resources.
     */
    H5Dclose(dset_id);
    H5Sclose(filespace);
    H5Sclose(memspace);
    H5Pclose(plist_id);
    H5Fclose(file_id);
		//f.close()
	t[5]=MPI_Wtime();
        gettimeofday(&now,NULL);
	t[7]=(double)(now.tv_sec)+(double)(now.tv_usec)*1e-6;
	sprintf(fout,"times_%2.2d_%7.7d_%2.2d" ,rank,jid,sub);
	file=fopen(fout,"w");
	k=0;
	for (j=1;j<6;j++) {
	    x=t[j];
	    fprintf(file,"%10.6f ,",x-t[k]);
	    k=k+1;
	}
	fprintf(file,"%f,%f,%10.6f\n",t[6],t[7],t[7]-t[6]);
	MPI_Finalize();
	}





	
	
