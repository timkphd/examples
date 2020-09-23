/************************************************************************************

A nontrivial MPI-IO example.


(1)  Reads a volume size, nx X ny X nz, from the command line.
(2)  Does a domain decomposisiton, assigning a portion of the volume to each processor
(3)  Allocates space on each processor for its portion of the volume
(4)  Fills the volume with integers, 1 to N=nx*ny*nz
(5)  Open a file, set the view to the beginning and write a header
(6)  Create a MPI datatype which is actually a description of how the data is laid out
(7)  We actually write a function of our data so we place our output data in a buffer
	(7a)  Find out how many times each processor will need to fill and write the buffer
	(7b)  Repeatidly fill and write the buffer using MPI_File_write_at_all
	(7c)  Since MPI_File_write_at_all is a collective and each processor must call it the
	      same number of times we optionally call MPI_File_write_at_all with no data
(8)  Close the file

    ================================================================= 
   | (c) Copyright 2007 The Regents of the University of California. |
   |     All Rights Reserved.                                        |
   |                                                                 |
   |     This work was produced under the sponsorship of the         |
   |     United States Department of Energy and the National         |
   |     Science Fondataion.                                         |
   |     The Government retains certain rights therein.              |
    ================================================================= 
    
author: Timothy H. Kaiser, Ph.D.
        tkaiser@sdsc.edu
        may 2007
        
portions: 
   author: Shawn Larsen, Ph.D.
   date  : march 1992
   where : llnl


************************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <mpi.h>
#include <sys/types.h>
#include <unistd.h>
#include <math.h>
#include <limits.h>

#define FLT int
#define NUM_VALS 1000000

int myid,ierr;	 

void mysubgrid0(int nx, int ny, int nz,
				int sx, int sy, int sz, 
				int x0, int y0, int z0,
				MPI_Datatype old_type,
				MPI_Offset *location,
				MPI_Datatype *new_type);
FLT *** getArrayF3D(long l, long l0, long l1, long m, long m0, long m1, long n, long n0, long n1);
void three ( int nodes, int *out3);
void mpDecomposition(int l, int m, int n, int nx, int ny, int nz, int node, int *dist);
void mpi_check(int err, char *line);
FLT getS3D(FLT ***vol,int l, int m, int n,int y0,int z0,int x0);

int main (int argc, char **argv) {
	int dist[6];
	int x0,y0,z0;
	int nx,ny,nz;
	int sx,sy,sz;
	int numprocs;
	char fname[80];
	int resultlen;
	long i,j,k;
	long ltmp,ntmp,mtmp,val;
	int ***vol,*ptr;
	double t2,t3,t4,t5,t6,t7,dt[6];
	int max_size,min_size,do_call,do_call_max,buf_size;
	int hl,header[3];
	long isize,i2;
	int l,n,m;
	int grid_l,grid_m,grid_n;	
	char name[MPI_MAX_PROCESSOR_NAME];
/* 	MPI_Info fileinfo; */
	MPI_File fh;
	MPI_Datatype filetype;
	MPI_Status status;
	MPI_Offset disp, offset;
	int sample;
	int gblsize[3],comp[3];	

	MPI_Init(&argc,&argv);
	MPI_Comm_rank( MPI_COMM_WORLD, &myid);
	MPI_Comm_size( MPI_COMM_WORLD, &numprocs);
	MPI_Get_processor_name(name,&resultlen);
	printf("process %d running on %s\n",myid,name);
/* we read and broadcast the global grid size (nx,ny,nz) */
	if(myid == 0) {
		if(argc != 4){
			printf("the grid size is not on the command line assuming 100 x 50 x 75\n");
			gblsize[0]=100;
			gblsize[1]=50;
			gblsize[2]=75;
		}
		else {
			gblsize[0]=atoi(argv[1]);
			gblsize[1]=atoi(argv[2]);
			gblsize[2]=atoi(argv[3]);
		}
	}
	MPI_Bcast(gblsize,3,MPI_INT,0,MPI_COMM_WORLD);
/********** a ***********/	
   
/* the routine three takes the number of processors and
   returns a 3d decomposition or topology.  this is simply
   a factoring of the number of processors into 3 integers
   stored in comp */
	three(numprocs,comp);
	
/* the routine mpDecomposition takes the processor topology and
   the global grid dimensions and maps the grid to the topology.
   mpDecomposition returns the number of cells a processor holds
   and the starting coordinates for its portion of the grid */
	if(myid == 0 ) {
   	 printf("input mpDecomposition %5d%5d%5d%5d%5d%5d\n",gblsize[1],gblsize[2],gblsize[0],  
   	                                                        comp[1],   comp[2],   comp[0]);
    }
	mpDecomposition( gblsize[1],  gblsize[2],  gblsize[0],  comp[1],  comp[2],  comp[0],myid,dist);
    printf("  out mpDecomposition %5d%5d%5d%5d%5d%5d%5d\n",myid,dist[0],dist[1],dist[2],
                                                                dist[3],dist[4],dist[5]);
/********** b ***********/	
    fflush(stdout);
    MPI_Barrier(MPI_COMM_WORLD);

/* global grid size */
    nx=gblsize[0];
	ny=gblsize[1];
	nz=gblsize[2];

/* amount that i hold */
	sx=dist[0];
	sy=dist[1];
	sz=dist[2];

/* my grid starts here */
	x0=dist[3];
	y0=dist[4];
	z0=dist[5];

/********** c ***********/	
/* allocate memory for our volume */
	vol=getArrayF3D((long)sy,(long)0,(long)0,(long)sz,(long)0,(long)0,(long)sx,(long)0,(long)0);

/* fill the volume with numbers 1 to global grid size */
/* the program from which this example was derived, e3d, 
   holds its data as a collection of vertical planes.  
   plane number increases with y.  that is why we loop
   on y with the outer most loop.  */
	k=1+(x0+nx*z0+(nx*nz)*y0);
	for (ltmp=0;ltmp<sy;ltmp++) {
		for (mtmp=0;mtmp<sz;mtmp++) {
			for (ntmp=0;ntmp<sx;ntmp++) {
				val=k+ntmp+  mtmp*nx	 + ltmp*nx*nz;
				if(val > (long)INT_MAX)val=(long)INT_MAX;
				vol[ltmp][mtmp][ntmp]=(int)val;
			}
		}
	}

/********** d ***********/	
/*********
    ierr=MPI_Info_create(&fileinfo);
*********/
t2=MPI_Wtime();
/* create a file name based on the grid size */
	for(j=1;j<80;j++) {
		fname[j]=(char)0;
	}
   sprintf(fname,"%s_%3.3d_%4.4d_%4.4d_%4.4d","mpiio_dat",numprocs,gblsize[0],gblsize[1],gblsize[2]);
/* we open the file fname for output, info is NULL */
    ierr=MPI_File_open(MPI_COMM_WORLD, fname,(MPI_MODE_RDWR | MPI_MODE_CREATE), MPI_INFO_NULL, &fh);
/* we write a 9 integer header */
    hl=3; 
/* set the view to the beginning of the file */
    ierr=MPI_File_set_view(fh, 0, MPI_INT, MPI_INT, "native",MPI_INFO_NULL);
/* process 0 writes the header */
    if(myid == 0) {
      header[0]=nx; header[1]=ny; header[2]=nz;
/* MPI_File_write_at is not a collective so only 0 calls it */
      ierr=MPI_File_write_at(fh, 0, header, hl, MPI_INT,&status);
    }
/********** 01 ***********/
    t2=MPI_Wtime();  
/* we create a description of the layout of the data */  
/* more on this later */ 
	printf("mysubgrid0 %5d%5d%5d%5d%5d%5d%5d%5d%5d%5d\n",myid,nx,ny,nz,sx,sy,sz,x0,y0,z0);
	mysubgrid0(nx, ny, nz,sx, sy, sz, x0, y0, z0, MPI_INT,&disp,&filetype);

/* length of the header */
	disp=disp+(4*hl); 
/* every processor "moves" past the header */
    ierr=MPI_File_set_view(fh, disp, MPI_INT, filetype, "native",MPI_INFO_NULL);
/********** 02 ***********/
/* we are going to create the data on the fly */
/* so we allocate a buffer for it */
    t3=MPI_Wtime();
    isize=sx*sy*sz;
    buf_size=NUM_VALS*sizeof(FLT);
    if( isize < NUM_VALS) {
      buf_size=isize*sizeof(FLT);
    }
    else {
      buf_size=NUM_VALS*sizeof(FLT);
    }
    ptr=(FLT*)malloc(buf_size);
    offset=0;
/* find the max and min number of isize of each processors buffer */
    ierr=MPI_Allreduce ( &isize, &max_size, 1, MPI_INT, MPI_MAX,  MPI_COMM_WORLD);
    ierr=MPI_Allreduce ( &isize, &min_size, 1, MPI_INT, MPI_MIN,  MPI_COMM_WORLD);
/********** 03 ***********/
    t7=0;
    dt[5]=0.0;
/* find out how many times each processor will dump its buffer */
    i=0;
    i2=0;
    do_call=0;
    sample=1;
    grid_l=y0+sy;
    grid_m=z0+sz;
    grid_n=x0+sx;
/* could just do division but that would be too easy */    
    for(l = y0; l < grid_l; l = l + sample) {
      for(m = z0; m < grid_m; m = m + sample) { 
        for(n = x0; n < grid_n; n = n + sample) {
          i++;
          i2++;
          if(i == isize  || i2 == NUM_VALS){
            do_call++;
            i2=0;
          } } } }
/* get the maximum number of many times a processor will dump its buffer */
    ierr= MPI_Allreduce ( &do_call, &do_call_max, 1, MPI_INT, MPI_MAX,  MPI_COMM_WORLD);
/********** 04 ***********/
/* finally we start to write the data */
    i=0;
    i2=0;
/* we loop over our grid filling the output buffer */
    for(l = y0; l < grid_l; l = l + sample) {
      for(m = z0; m < grid_m; m = m + sample) { 
        for(n = x0; n < grid_n; n = n + sample) {
//          ptr[i2] = getS3D(vol,l, m, n,y0,z0,x0); 
          ptr[i2]=(myid+1);
//          ptr[i2]=ptr[i2] / (myid+1);

          
          i++;
          i2++;
/********** 05 ***********/
/* when we have all our data or the buffer is full we write */
          if(i == isize  || i2 == NUM_VALS){
            t5=MPI_Wtime();
            t7++;
            if((isize == max_size) && (max_size == min_size)) {
/* as long as every processor has data to write we use the collective version */
/* the collective version of the write is MPI_File_write_at_all */
              ierr=MPI_File_write_at_all(fh, offset, ptr, i2, MPI_INT,&status);
              do_call_max=do_call_max-1;
            }
            else {
/* if only I have  data to write then we use MPI_File_write_at */
              /*ierr=MPI_File_write_at(fh, offset, ptr, i2, MPI_INT,&status);*/
/* Wait! Why was that line commented out?  Why are we using MPI_File_write_at_all? */
/* Answer:  Some versions of MPI work better using MPI_File_write_at_all */
/* What happens if some processors are done writing and don't call this? */
/* Answer:  See below. */
              ierr=MPI_File_write_at_all(fh, offset, ptr, i2, MPI_INT,&status);
              do_call_max=do_call_max-1;
            }
            offset=offset+i2;
            i2=0;
            t6=MPI_Wtime();
            dt[5]=dt[5]+(t6-t5);
          }
        }
      }
    }
/********** 06 ***********/
/* Here is where we fix the problem of unmatched calls to MPI_File_write_at_all*/
/* If a processor is done with its writes and others still have */
/* data to write the the done processor just calls  */
/* MPI_File_write_at_all but this 0 values to write */
/* All processors call MPI_File_write_at_all the same number of */
/* times so everyone is happy */
    while(do_call_max > 0) {
      ierr=MPI_File_write_at_all(fh, (MPI_Offset)0, (void *)0, 0, MPI_INT,&status);
      do_call_max=do_call_max-1;
    }
/* We finally close the file */
    ierr=MPI_File_close(&fh);
/*********
    ierr=MPI_Info_free(&fileinfo);
*********/
    t3=MPI_Wtime();
    t2=t3-t2;
    t3=t2;
    ierr=MPI_Allreduce ( &t7, &t3, 1, MPI_DOUBLE, MPI_MIN,  MPI_COMM_WORLD);
    ierr=MPI_Allreduce ( &t7, &t4, 1, MPI_DOUBLE, MPI_MAX,  MPI_COMM_WORLD);
    if(myid == 0){ 
        printf("# writes= %g  %g\n",t3,t4);
    }
    ierr=MPI_Allreduce ( &dt[5], &t3, 1, MPI_DOUBLE, MPI_MIN,  MPI_COMM_WORLD);
    ierr=MPI_Allreduce ( &dt[5], &t4, 1, MPI_DOUBLE, MPI_MAX,  MPI_COMM_WORLD);
    if(myid == 0){ 
        printf("write time= %g  %g\n",t3,t4);
    }
    ierr=MPI_Allreduce ( &t2, &t3, 1, MPI_DOUBLE, MPI_MIN,  MPI_COMM_WORLD);
    ierr=MPI_Allreduce ( &t2, &t4, 1, MPI_DOUBLE, MPI_MAX,  MPI_COMM_WORLD);
    if(myid == 0){ 
        printf("total time= %g  %g\n",t3,t4);
    }
    MPI_Finalize();
    exit(0);
/********** 07 ***********/
}

/* our dummy function that returns a function
   of our input array.  this version just maps
   the global volume coordinates l,m,n to the
   local coordinates */
FLT getS3D(FLT ***vol,int l, int m, int n,int y0,int z0,int x0) {
	int ltmp,mtmp,ntmp;
	ltmp=l-y0;
	mtmp=m-z0;
	ntmp=n-x0;
	return(vol[ltmp][mtmp][ntmp]);
}


/*  we have two versions of mysubgrid0, the routine that
    creates the  description of the data layout.  the
    second one is actually perfered.  it uses a single
    call to the mpi routine MPI_Type_create_subarray with
    the the grid description as input.  what we get back is
    a data type that is a 3d strided volume.  unfortunately, 
    MPI_Type_create_subarray does not work for 3d arrays
    for some versions of MPI, in particular LAM.  
    
    the first version of mysubgrid0 builds up the description
    from primatives.  we start with x, then create VECT
    which is a vector of x values.  we then take a collection
    of VECTs and create a vertical slice, TWOD.  note 
    that the distance between each VECT in TWOD is given
    in indices[i].  we next take a collection of vertical
    slices and create our volume.  again we have the distances
    between the slices given in indices[i]
    
    the offset to the beginning of our structure is stored in 
    location.
    */
#ifdef DO2
void mysubgrid0(int nx, int ny, int nz,
                int sx, int sy, int sz, 
                int x0, int y0, int z0,
                MPI_Datatype old_type,
                MPI_Offset *location,
                MPI_Datatype *new_type)
{
	MPI_Datatype VECT;
#define BSIZE 5000
	int blocklens[BSIZE];
	MPI_Aint indices[BSIZE];
	MPI_Datatype old_types[BSIZE];
	MPI_Datatype TWOD;
	int i;
	if(myid == 0)printf("using mysubgrid version 1\n");
	if(sz > BSIZE)mpi_check(-1,"sz > BSIZE, increase BSIZE and recompile");
	ierr=MPI_Type_contiguous(sx,old_type,&VECT);
    ierr=MPI_Type_commit(&VECT);
    for (i=0;i<sz;i++) {
    	blocklens[i]=1;
    	old_types[i]=VECT;
    	indices[i]=i*nx*4;
    }
	ierr=MPI_Type_struct(sz,blocklens,indices,old_types,&TWOD);
    ierr=MPI_Type_commit(&TWOD);
    
    for (i=0;i<sy;i++) {
    	blocklens[i]=1;
    	old_types[i]=TWOD;
    	indices[i]=i*nx*nz*4;
    }

	ierr=MPI_Type_struct(sy,blocklens,indices,old_types,new_type);
    ierr=MPI_Type_commit(new_type);
    *location=4*(x0+nx*z0+(nx*nz)*y0);
}
#else
void mysubgrid0(int nx, int ny, int nz,
                int sx, int sy, int sz, 
                int x0, int y0, int z0,
				MPI_Datatype old_type,
				MPI_Offset *location,
				MPI_Datatype *new_type)
{
	int gsizes[3],lsizes[3],istarts[3];
	gsizes[2]=nx;  gsizes[1]=nz;  gsizes[0]=ny;
	lsizes[2]=sx;  lsizes[1]=sz;  lsizes[0]=sy;
	istarts[2]=x0; istarts[1]=z0; istarts[0]=y0;
	if(myid == 0)printf("using mysubgrid version 2\n");
	ierr=MPI_Type_create_subarray(3,gsizes,lsizes,istarts,MPI_ORDER_C,old_type,new_type);
	ierr=MPI_Type_commit(new_type);
	*location=0;
}

#endif

/* the routine three takes the number of processors and
   returns a 3d decomposition or topology.  this is simply
   a factoring of the number of processors into 3 integers
   stored in comp */

void two ( int nodes, int *out2);

void three ( int nodes, int *out3) {
int i,out2[2];
two(nodes,out2);
i=out2[0];
out3[2]=out2[1];
two(i,out3);
/* exchange 0 and 2, just looks better this way */
i=out3[2];out3[2]=out3[0];out3[0]=i;
}

void two ( int nodes, int *out) {
        int nrow, ncol,i;
        nrow=(int)sqrt((double)nodes);
        ncol=nodes/nrow;
        while(nrow*ncol != nodes){
                nrow=nrow+1;
                ncol=nodes/nrow;
        }
        if(nrow > ncol) {
           i=ncol;
           ncol=nrow;
           nrow=i;
        }
        out[0]=nrow;
        out[1]=ncol;
}

/******************************************************************************
   the routines mpDecomposition and getArrayF3D were adapted from:

   e3d: 2D/3D elastic finite-difference synthetics on staggered grid (Levandar)
   author: shawn larsen
   date  : march 1992
   where : llnl

*****************************************************************************/

/* the routine mpDecomposition takes the processor topology and
   the global grid dimensions and maps the grid to the topology.
   mpDecomposition returns the number of cells a processor holds
   and the starting coordinates for its portion of the grid */

void mpDecomposition(int l, int m, int n, int nx, int ny, int nz, int node, int *dist)
{ 
	int nnode, mnode, rnode;
	int   grid_n,grid_n0,grid_m,grid_m0,grid_l,grid_l0;

	/* x decomposition */
	rnode     = node%nx;
	mnode     = (n%nx);
	nnode     = (n/nx);
	grid_n   = (rnode < mnode) ? (nnode + 1) : (nnode);
	grid_n0  = rnode*nnode;
	grid_n0 += (rnode < mnode) ? (rnode) : (mnode);

	/* z decomposition */
	rnode     = (node%(nx*nz))/nx;
	mnode     = (m%nz);
	nnode     = (m/nz);
	grid_m   = (rnode < mnode) ? (nnode + 1) : (nnode);
	grid_m0  = rnode*nnode;
	grid_m0 += (rnode < mnode) ? (rnode) : (mnode);

	/* y decomposition */
	rnode     = node/(nx*nz);
	mnode     = (l%ny);
	nnode     = (l/ny);
	grid_l   = (rnode < mnode) ? (nnode + 1) : (nnode);
	grid_l0  = rnode*nnode;
	grid_l0 += (rnode < mnode) ? (rnode) : (mnode);
	
	dist[0]=grid_n;   dist[1]=grid_l;   dist[2]=grid_m;
	dist[3]=grid_n0;  dist[4]=grid_l0;  dist[5]=grid_m0;

}


/*  getArrayF3D returns a pointer to a volume */

FLT *** getArrayF3D(long l, long l0, long l1, long m, long m0, long m1, long n, long n0, long n1)
{
	FLT ***v, *data;
/*	int j, k, p, pl, pm, pn, extra; */
	long j, k, p, pl, pm, pn, extra;
	extra = 1;
	pl = (l + l0 + l1);
	pm = (m + m0 + m1);
	pn = (n + n0 + n1);
	p  = pl*pm*pn; 
	data = NULL;
	data = (FLT *) malloc(p*sizeof(FLT));
	if (data == NULL)mpi_check(-1, "getArrayF3D 1");
	v = NULL;
	v = (FLT ***) malloc((l + l0 + l1 + extra)*sizeof(FLT **));
	if (v == NULL)mpi_check(-1, "getArrayF3D 2");
	v += l0;
	for(k = -l0; k < l + l1; k++) {
		v[k] = NULL;
		v[k] = (FLT **) malloc((m + m0 + m1)*sizeof(FLT *));
		if (v[k] == NULL)mpi_check(-1, "getArrayF3D 3");
		v[k] += m0;
		}
	v[l+l1] = NULL;
	v[l+l1] = (FLT **) malloc(1*sizeof(FLT *));
	if (v[l+l1] == NULL)mpi_check(-1, "getArrayF3D 4");
	v[l+l1][0] = data;
	for(k = -l0; k < l + l1; k++) for(j = -m0; j < m + m1; j++) {
		v[k][j] = data + (k+l0)*(pm)*(pn) + (j+m0)*(pn) + n0;
		}
	return(v);
}

void mpi_check(int err, char *line)
{
	if(err != 0) {
		printf("mpiio failure -- process %d had an error in routine %s	calling abort\n",myid,line);
		MPI_Abort( MPI_COMM_WORLD, -1);
	}
}
