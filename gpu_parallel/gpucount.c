#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>
main() {
	int num_devices;
	cudaGetDeviceCount(&num_devices);
	printf("%d",num_devices);
}
