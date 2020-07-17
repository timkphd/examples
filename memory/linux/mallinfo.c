#ifndef __APPLE__
#include <malloc.h>
#endif
#include <stdio.h>
#include <stdlib.h>
// #include "tlpi_hdr.h"

static void
display_mallinfo(void)
{
   struct mallinfo mi;

   mi = mallinfo();

   printf("Total non-mmapped bytes (arena):       %d\n", mi.arena);
   printf("# of free chunks (ordblks):            %d\n", mi.ordblks);
   printf("# of free fastbin blocks (smblks):     %d\n", mi.smblks);
   printf("# of mapped regions (hblks):           %d\n", mi.hblks);
   printf("Bytes in mapped regions (hblkhd):      %d\n", mi.hblkhd);
   printf("Max. total allocated space (usmblks):  %d\n", mi.usmblks);
   printf("Free bytes held in fastbins (fsmblks): %d\n", mi.fsmblks);
   printf("Total allocated space (uordblks):      %d\n", mi.uordblks);
   printf("Total free space (fordblks):           %d\n", mi.fordblks);
   printf("Topmost releasable block (keepcost):   %d\n", mi.keepcost);
}

#define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
					   } while (0)

int
main(int argc, char *argv[])
{
#define MAX_ALLOCS 2000000
   char *alloc[MAX_ALLOCS];
   int numBlocks, j, freeBegin, freeEnd, freeStep;
   size_t blockSize;

   if (argc < 3 || strcmp(argv[1], "--help") == 0) {
	   printf("%s num-blocks block-size [free-step [start-free [end-free]]]\n", argv[0]);
           exit(1);
  }

   numBlocks = atoi(argv[1]);
   blockSize = atoll(argv[2]);
   printf("%d %ld\n",numBlocks,blockSize);
   freeStep = (argc > 3) ? atoi(argv[3]) : 1;
   freeBegin = (argc > 4) ? atoi(argv[4]) : 0;
   freeEnd = (argc > 5) ? atoi(argv[5]) : numBlocks;

   printf("============== Before allocating blocks ==============\n");
   display_mallinfo();

   for (j = 0; j < numBlocks; j++) {
	   if (numBlocks >= MAX_ALLOCS)
		   errExit("Too many allocations");

	   alloc[j] = malloc(blockSize);
	   if (alloc[j] == NULL)
		   errExit("malloc");
   }

   printf("\n============== After allocating blocks ==============\n");
   display_mallinfo();

   for (j = freeBegin; j < freeEnd; j += freeStep)
	   free(alloc[j]);

   printf("\n============== After freeing blocks ==============\n");
   display_mallinfo();

   exit(0);
}
