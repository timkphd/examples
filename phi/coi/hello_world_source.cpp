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


// This tutorial is simple tutorial that
// 1) gets the number of Intel (R) Xeon Phi(TM) engines available
// 2) gets the first available Intel (R) Xeon Phi(TM) engine
// 3) creates a process
// 4) destroys the process

#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#endif
#include <string.h>
#include <source/COIProcess_source.h>
#include <source/COIEngine_source.h>

int main(int argc,char **argv)
{
    COIRESULT               result = COI_ERROR;
    COIPROCESS              proc;
    COIENGINE               engine;
    uint32_t                num_engines = 0;
//    const char*             SINK_NAME = "hello_world_sink_mic";
    char                    SINK_NAME[128];
    int8_t                  sink_return;
    uint32_t                exit_reason;

    if(argc > 1) {
	stpncpy(SINK_NAME,argv[1],128);
    }
    else {
	stpncpy(SINK_NAME,"hello_world_sink_mic",128);
    }

    // Make sure there is an Intel(R) Xeon Phi(TM) device available
    //
    result = COIEngineGetCount(COI_ISA_MIC, &num_engines);
    if (result != COI_SUCCESS)
    {
        printf("COIEngineGetCount result %s\n", COIResultGetName(result));
        return -1;
    }

    printf("%u engines available\n", num_engines);

    // If there isn't at least one engine, there is something wrong
    //
    if (num_engines < 1)
    {
        printf("ERROR: Need at least 1 engine\n");
        return -1;
    }

    // Get a handle to the "first" Intel(R) Xeon Phi(TM) engine
    //
    result = COIEngineGetHandle(COI_ISA_MIC, 0, &engine);
    if (result != COI_SUCCESS)
    {
        printf("COIEngineGetHandle result %s\n", COIResultGetName(result));
        return -1;
    }
    printf("Got engine handle\n");

    // The following call creates a process on the sink.
    // Intel® Coprocessor Offload Infrastructure (Intel® COI)  will automatically load any dependent libraries and run the "main"
    // function in the binary.
    //
    result = COIProcessCreateFromFile(
        engine,         // The engine to create the process on.
        SINK_NAME,      // The local path to the sink side binary to launch.
        0, NULL,        // argc and argv for the sink process.
        false, NULL,    // Environment variables to set for the sink process.
        true, NULL,     // Enable the proxy but don't specify a proxy root path.
        0,              // The amount of memory to pre-allocate
                        // and register for use with COIBUFFERs.
        NULL,           // Path to search for dependencies
        &proc           // The resulting process handle.
    );
    if (result != COI_SUCCESS)
    {
        printf("COIProcessCreateFromFile result %s\n",
               COIResultGetName(result));
        return -1;
    }

    printf("Sink process created, press enter to destroy it.\n");
    getchar();

    // Destroy the process
    //
    result = COIProcessDestroy(
        proc,           // Process handle to be destroyed
        -1,             // Wait indefinitely until main() (on sink side) returns
        false,          // Don't force to exit. Let it finish executing
                        // functions enqueued and exit gracefully
        &sink_return,   // Don't care about the exit result.
        &exit_reason
    );

	if (result != COI_SUCCESS)
    {
        printf("COIProcessDestroy result %s\n", COIResultGetName(result));
        return -1;
    }

    printf("Sink process returned %d\n", sink_return);
    printf("Sink exit reason ");
    switch (exit_reason)
    {
        case 0:
            printf("SHUTDOWN OK\n");
        break;
        default:
#ifndef _WIN32
            printf("Exit reason %d - %s\n",
                   exit_reason, strsignal(exit_reason));
#else
            printf("Exit reason %d\n",
                   exit_reason);

#endif
    }

    return ((exit_reason == 0) ? 0 : -1);
}
