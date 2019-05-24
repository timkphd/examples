/*
* Copyright (C) Intel Corporation (2012)
*
* This file is subject to the Intel Sample Source Code License. 
* A copy of the Intel Sample Source Code License is included. 
*
* Linux OS: 	/opt/intel/mic/LICENSE/ 
* Windows: 	C:\Program Files\Intel\MPSS\
*
*/


#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#endif
#include <omp.h>
// main is automatically called whenever the source creates a process.
// However, once main exits, the process that was created exits.
int main(int , char**)
{
    // This will get printed to the sink's stdout if the process is
    // created with a proxy enabled (arg 7 of ProcessCreateFromFile).
#pragma omp parallel
{
    printf("Hello from the %d sink!\n",omp_get_thread_num());
}
// stdout may not be line buffered over the proxy so a flush of stdout
    // is recommended.
    fflush(stdout);

    return 0;
}
