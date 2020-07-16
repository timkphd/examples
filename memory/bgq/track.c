/* compile instructions:
 * mpicc -std=gnu99 -c -g -O0 -Wall fortran_memory.c */

#include <spi/include/kernel/memory.h>
#include <spi/include/kernel/location.h>

/* u = used
 * a = available */

void memory_info(double * heapu, double * stacku, double * heapa, double * stacka)
{
  //uint64_t shared, persist, guard, mmap;
  //Kernel_GetMemorySize(KERNEL_MEMSIZE_SHARED,   &shared);
  //Kernel_GetMemorySize(KERNEL_MEMSIZE_PERSIST,  &persist);
  //Kernel_GetMemorySize(KERNEL_MEMSIZE_GUARD,    &guard);
  //Kernel_GetMemorySize(KERNEL_MEMSIZE_MMAP,     &mmap);

  uint64_t heap_used, stack_used, heap_avail, stack_avail;
  Kernel_GetMemorySize(KERNEL_MEMSIZE_HEAP,       &heap_used);
  Kernel_GetMemorySize(KERNEL_MEMSIZE_STACK,      &stack_used);
  Kernel_GetMemorySize(KERNEL_MEMSIZE_HEAPAVAIL,  &heap_avail);
  Kernel_GetMemorySize(KERNEL_MEMSIZE_STACKAVAIL, &stack_avail);

  *heapu  = (double) heap_used;
  *stacku = (double) stack_used;
  *heapa  = (double) heap_avail;
  *stacka = (double) stack_avail;

  return;
}

void memory_info_(double * heapu, double * stacku, double * heapa, double * stacka)
{
    memory_info(heapu, stacku, heapa, stacka);
    return;
}
