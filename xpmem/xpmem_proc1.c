/*
 * xpmem_proc1: process one capable of running various XPMEM tests
 *
 * Copyright (c) 2010 Cray, Inc.
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file "COPYING" in the main directory of this archive
 * for more details.
 */
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/wait.h>

#include <xpmem.h>
#include <xpmem_test.h>

/**
 * test_base - a simple test to share and attach
 * Description:
 *      Creates a share (initialized to a random value), calls a second process
 *	to attach to the shared address and increment its value.
 * Return Values:
 *	Success: 0
 *	Failure: -1
 */
int test_base(test_args *xpmem_args)
{
	int i, ret=0, *data, expected;
	xpmem_segid_t segid;
	segid = make_share(&data, SHARE_SIZE);
        for (i = 0; i < SHARE_INT_SIZE; i++) {
		*(data + i)=i;
	}
	if (segid == -1) {
		perror("xpmem_make");
		xpmem_args->share[LOCK_INDEX] = 1;
		return -1;
	}

	printf("xpmem_proc1: mypid = %d\n", getpid());
	printf("xpmem_proc1: sharing %ld bytes\n", SHARE_SIZE);
	printf("xpmem_proc1: segid = %llx at %p\n\n", segid, data);

	/* Copy data to mmap share */
	sprintf(xpmem_args->share, "%llx", segid);

	/* Give control back to xpmem_master */
	xpmem_args->share[LOCK_INDEX] = 1;

	/* Wait for xpmem_proc2 to finish */
	lockf(xpmem_args->lock, F_LOCK, 0);
	lockf(xpmem_args->lock, F_ULOCK, 0);

	printf("xpmem_proc1: verifying data...");
	expected=1;
	for (i = 0; i < SHARE_INT_SIZE; i++) {
		// printf("%d %d\n",*(data + i),i + expected);
		if (*(data + i) != i + expected) {
			printf("xpmem_proc1: ***mismatch at %d: expected %d "
				"got %d\n", i, i + expected, *(data + i));
			ret = -1;
		}
	}
	printf("done\n");

	unmake_share(segid, data, SHARE_SIZE);

	return ret;
}

int main(int argc, char **argv)
{
	test_args xpmem_args;


	if ((xpmem_args.fd = open("/tmp/xpmem.share", O_RDWR)) == -1) {
		perror("open xpmem.share");
		return -1;
	}
	if ((xpmem_args.lock = open("/tmp/xpmem.lock", O_RDWR)) == -1) {
		perror("open xpmem.lock");
		return -1;
	}
	xpmem_args.share = mmap(0, TMP_SHARE_SIZE, PROT_READ|PROT_WRITE,
			MAP_SHARED, xpmem_args.fd, 0);
	if (xpmem_args.share == MAP_FAILED) {
		perror("mmap");
		return -1;
	}

	return (test_base(&xpmem_args));
}


int test_fork(test_args *xpmem_args){};
int test_two_attach(test_args *xpmem_args){};
int test_two_shares(test_args *xpmem_args){};
