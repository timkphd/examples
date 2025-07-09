/*
 * xpmem_master: controller thread for various XPMEM tests
 *
 * Copyright (c) 2010 Cray, Inc.
 * Copyright (c) 2025 NREL for MPI version 
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file "COPYING" in the main directory of this archive
 * for more details.
 *
 *     cc -I. -I/nopt/xpmem/include -L/nopt/xpmem/lib -lxpmem combined.c -o combined
 *     srun -n 2 ./combined
 */

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>
#include <xpmem.h>
#include <xpmem_test.h>

#include "mpi.h"
MPI_Status status; 
#define m0 0
#define m1 1


#define test_result(name, val1, val2) (((val1) == (val2)) ?	\
		printf("\n\n==== %s PASSED ====\n\n", (name)) :	\
		printf("\n\n==== %s FAILED ====\n\n", (name)))

int test_base1()
{
	char astr[128];
	int i, ret=0, *data, expected;
	xpmem_segid_t segid;
// set up the shared memory location.  Address is in segid.
	segid = make_share(&data, SHARE_SIZE);
        for (i = 0; i < SHARE_INT_SIZE; i++) {
		*(data + i)=i;
	}
	if (segid == -1) {
		perror("xpmem_make");
	}

	printf("xpmem_proc1: mypid = %d\n", getpid());
	printf("xpmem_proc1: sharing %ld bytes\n", SHARE_SIZE);
	printf("xpmem_proc1: segid = %llx at %p\n\n", segid, data);
	sprintf(astr, "%llx", segid);
// We tell the other process where to find the memory block.
// This could/should be sent as a long but the orginal code
// used a string put in a file which is then read by the second
// process.
	MPI_Send(&astr,128,MPI_CHARACTER,m1,2345,MPI_COMM_WORLD);
	
// This MPI_Recv just a synchronization.  The Recv happens after
// the second process updates the memory block.  In a real
// code you would not use MPI for this but have a mutex like
// block that gets updated.
	MPI_Recv(&astr,128,MPI_CHARACTER,m1,2345,MPI_COMM_WORLD,&status);

	printf("xpmem_proc1: verifying data...");
	expected=1;
	for (i = 0; i < SHARE_INT_SIZE; i++) {
		if (*(data + i) != i + expected) {
			printf("xpmem_proc1: ***mismatch at %d: expected %d "
				"got %d\n", i, i + expected, *(data + i));
			ret = -1;
			return ret;
		}
	}
	printf("\nxpmem_proc1: pass...");
	unmake_share(segid, data, SHARE_SIZE);
	return ret;
}

int test_base2()
{
	char astr[128];
	xpmem_segid_t segid;
	xpmem_apid_t apid;
	int i, ret=0, *data;
// We get the memory location as a string from the first process.
// This could/should be sent as a long but the orginal code
// used a string.  
	MPI_Recv(&astr,128,MPI_INT,m0,2345,MPI_COMM_WORLD,&status);
	segid = strtol(astr, NULL, 16);
	data = attach_segid(segid, &apid);
	if (data == (void *)-1) {
		perror("xpmem_attach");
		return -2;
	}
	printf("xpmem_proc2: mypid = %d\n", getpid());
	printf("xpmem_proc2: segid = %llx\n", segid);
	printf("xpmem_proc2: attached at %p\n", data);
// Update the bufffer.
	printf("xpmem_proc2: adding 1 to all elems\n\n");
	for (i = 0; i < SHARE_INT_SIZE; i++) {
		if (i < 10  || i >  (SHARE_INT_SIZE-10))printf("%d\n",*(data + i));
		if (i == 10 || i == (SHARE_INT_SIZE-10))printf("...\n...\n");
		if (*(data + i) != i) {
			printf("xpmem_proc2: ***mismatch at %d: expected %d "
				"got %d\n", i, i, *(data + i));
			ret = -2;
		}
		*(data + i) += 1;
	}
	sprintf(astr,"%s","done");
// Tell the other process we are done.   In a real code 
// you would not use MPI for this but have a mutex like
// block that gets updated.
	MPI_Send(&astr,128,MPI_CHARACTER,m0,2345,MPI_COMM_WORLD);
	xpmem_detach(data);
	xpmem_release(apid);
	return ret;
}

int main(int argc, char** argv){
    int mpi_err,numnodes,myid;
    int value1,value2;
    test_args xpmem_args;
    mpi_err=MPI_Init(&argc,&argv);
    mpi_err=MPI_Comm_size(MPI_COMM_WORLD,&numnodes);
    mpi_err=MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    if (myid == 0)printf("XPMEM version = %x\n\n", xpmem_version());
    if (myid == m0)value1=test_base1();
    if (myid == m1)value2=test_base2();
    MPI_Barrier(MPI_COMM_WORLD);
    if (myid == 0){
	    sleep(0.5);
	    printf("\n\n\n"); 
	    test_result("base",value1,value2);
    }
    MPI_Finalize();
}

