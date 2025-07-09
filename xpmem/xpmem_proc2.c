/*
 * xpmem_proc2: thread two of various XPMEM tests
 *
 * Copyright (c) 2010 Cray, Inc.
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file "COPYING" in the main directory of this archive
 * for more details.
 */
#include <time.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>

#include <xpmem.h>
#include <xpmem_test.h>

/**
 * test_base - a simple test to share and attach
 * Description:
 *      Creates a share (initialized to a random value), calls a second process
 *	to attach to the shared address and increment its value.
 * Return Values:
 *	Success: 0
 *	Failure: -2
 */
int test_base(test_args *xpmem_args)
{
	xpmem_segid_t segid;
	xpmem_apid_t apid;
	int i, ret=0, *data;

	segid = strtol(xpmem_args->share, NULL, 16);
	data = attach_segid(segid, &apid);
	if (data == (void *)-1) {
		perror("xpmem_attach");
		return -2;
	}

	printf("xpmem_proc2: mypid = %d\n", getpid());
	printf("xpmem_proc2: segid = %llx\n", segid);
	printf("xpmem_proc2: attached at %p\n", data);

	printf("xpmem_proc2: adding 1 to all elems\n\n");
	for (i = 0; i < SHARE_INT_SIZE; i++) {
		printf("%d\n",*(data + i));
		if (*(data + i) != i) {
			printf("xpmem_proc2: ***mismatch at %d: expected %d "
				"got %d\n", i, i, *(data + i));
			ret = -2;
		}
		*(data + i) += 1;
	}

	xpmem_detach(data);
	xpmem_release(apid);

	return ret;
}

int main(int argc, char **argv)
{
	test_args xpmem_args;


	if ((xpmem_args.fd = open("/tmp/xpmem.share", O_RDWR)) == -1) {
		perror("open");
		return -2;
	}
	xpmem_args.share = mmap(0, TMP_SHARE_SIZE, PROT_READ|PROT_WRITE,
			MAP_SHARED, xpmem_args.fd, 0);
	if (xpmem_args.share == MAP_FAILED) {
		perror("mmap");
		return -2;
	}

	return (test_base(&xpmem_args));
}

int test_fork(test_args *xpmem_args){};
int test_two_attach(test_args *xpmem_args){};
int test_two_shares(test_args *xpmem_args){};


