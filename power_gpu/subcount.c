#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>
int cudaGetDeviceCount(int *i);
int cudaRuntimeGetVersion(int *i);
int cudaDriverGetVersion(int *i);
int getcount(int task, char* node  ){
	int num_devices;
        int rt,dr;
	cudaGetDeviceCount(&num_devices);
	printf("info gpus=%d task=%d node=%s",num_devices,task,node);
        if(num_devices > 0 ) {
         cudaRuntimeGetVersion(&rt);
         cudaDriverGetVersion(&dr);
         printf(" RuntimeVersion= %d  DriverVersion= %d\n",rt,dr);
        }
        if (num_devices > 0 ) 
          return 0;
        else 
          return 1;
}
