#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
main() {
 char name[128],fname[128];
 pid_t mypid;
 FILE *f;

/* get the process id */
mypid=getpid();
/* get the host name */
gethostname(name, 128);
/* make a file name based on these two */
sprintf(fname,"%s_%8.8d",name,(int)mypid);
/* open and write to the file */
f=fopen(fname,"w");
fprintf(f,"C says hello from %d on %s\n",(int)mypid,name);
}
