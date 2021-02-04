#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>
int cudaGetDeviceCount(int *i);
int cudaRuntimeGetVersion(int *i);
int cudaDriverGetVersion(int *i);
int main(int argc, char **argv) {
	int num_devices;
        int rt,dr;
	cudaGetDeviceCount(&num_devices);
	printf("%d",num_devices);
        if(num_devices > 0 && argc > 1) {
         cudaRuntimeGetVersion(&rt);
         cudaDriverGetVersion(&dr);
         printf("\nRuntimeVersion= %d  DriverVersion= %d\n",rt,dr);
        }
        if (num_devices > 0 ) 
          return 0;
        else 
          return 1;
}
