#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

long get_cpu_id()
{
#include <sys/syscall.h>
#ifndef SYS_gettid
#error "SYS_gettid unavailable on this system"
#endif
#define gettid() ((pid_t)syscall(SYS_gettid))
    int mypid,mytid;
    char fstring[128];
    mypid=(int)getpid();
    mytid=(int)gettid();
    FILE* procfile = fopen("/proc/self/stat", "r");
    if (mytid != mypid) {
        fclose(procfile);
    	sprintf(fstring,"/proc/%d/task/%d/stat",mypid,mytid);
    	//printf("%s\n",fstring);
    	FILE* procfile = fopen(fstring, "r");
    }
    long to_read = 8192;
    char buffer[to_read];
    int read = fread(buffer, sizeof(char), to_read, procfile);
    fclose(procfile);

    // Field with index 38 (zero-based counting) is the one we want
    char* line = strtok(buffer, " ");
    for (int i = 1; i < 38; i++)
    {
        line = strtok(NULL, " ");
    }

    line = strtok(NULL, " ");
    long cpu_id = atoi(line);
    return cpu_id;
}
