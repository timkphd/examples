#include <sys/time.h>
void WTIME(int *isec, int *nsec)
{
        struct timeval tb;
        struct timezone tz;
        int iret;
        iret=gettimeofday(&tb,(void*)&tz); 
        *isec=tb.tv_sec;
        *nsec=tb.tv_usec * 1000;
}

