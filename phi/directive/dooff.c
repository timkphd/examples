#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#define N  1000
__attribute__((target(mic)))  int data[N];
__attribute__((target(mic))) void MyFunction(int *mydata) { 
	int i;
	printf("Hello world! I have %ld logical cores.\n", sysconf(_SC_NPROCESSORS_ONLN ));
          for (i = 0; i < 5; i++)
			data[i] = i; 
}
int main(int argc, char * argv[] ) { 
	int i,k;
	printf("Hello world! I have %ld logical cores.\n", sysconf(_SC_NPROCESSORS_ONLN ));
        printf("enter k:");
	scanf("%d",&k);
	for ( i = 0; i < N; i++)
		data[i] = k; 
#pragma offload target(mic)
	{
		MyFunction(data);
	} 
	for ( i = 0; i < 10; i++)
		printf("%d\n",data[i]); 
}

