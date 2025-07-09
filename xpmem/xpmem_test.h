#ifndef _XPMEM_TEST_H
#define _XPMEM_TEST_H

#include <stdlib.h>
#include <unistd.h>

#define NR_TEST_PAGES 	4
#define PAGE_SIZE	sysconf(_SC_PAGE_SIZE)
#define SHARE_SIZE	NR_TEST_PAGES * PAGE_SIZE
#define PAGE_INT_SIZE	(PAGE_SIZE / sizeof(int))
#define SHARE_INT_SIZE	(SHARE_SIZE / sizeof(int))

/* Used to specify size of /tmp/xpmem.share */
#define TMP_SHARE_SIZE	32
#define LOCK_INDEX	TMP_SHARE_SIZE - 1
#define COW_LOCK_INDEX	TMP_SHARE_SIZE - 2

xpmem_segid_t make_share(int **data, size_t size)
{
	xpmem_segid_t segid;
	int i;
	int *ptr;

	ptr = mmap(NULL, size, PROT_READ | PROT_WRITE,
		     MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
	if (ptr == MAP_FAILED) {
		perror("mmap");
		return -1;
	}

	for (i=0; i < (size / sizeof(int)); i++)
		*(ptr + i) = i;

	segid = xpmem_make(ptr, size, XPMEM_PERMIT_MODE, (void *)0666);

	*data = ptr;
	return segid;
}

int unmake_share(xpmem_segid_t segid, int *data, size_t size)
{
	int ret;

	ret = xpmem_remove(segid);
	if (munmap(data, size) == -1) {
		perror("munmap");
		return -1;
	}

	return ret;
}

void *attach_segid(xpmem_segid_t segid, xpmem_apid_t *apid)
{
	struct xpmem_addr addr;
	void *buff;

	*apid = xpmem_get(segid, XPMEM_RDWR, XPMEM_PERMIT_MODE, NULL);
	if (*apid == -1) {
		perror("xpmem_get");
		return (void *)-1;
	}

	addr.apid = *apid;
	addr.offset = 0;
	buff = xpmem_attach(addr, SHARE_SIZE, NULL);

	return buff;
}

/* Structs for test functions */
typedef struct {
	int fd, lock;
	char *share;
//	int add;
} test_args;


/* Test function prototypes */
int test_base(test_args*);

#endif /* _XPMEM_TEST_H */
