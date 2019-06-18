#define _GNU_SOURCE 
#include <sys/types.h> 
#include <unistd.h> 
#include <sched.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <stdio.h> 
#include <assert.h> 
 
int sched_getcpu(); 
 
void findcore (int *ic) 
{ 
    int cpu; 
    ic[0] = sched_getcpu(); 
} 
void forcecore (int *core) { 
	cpu_set_t set; 
	pid_t getpid(void); 
	CPU_ZERO(&set);        // clear cpu mask 
        int bonk; 
        bonk=*core; 
	CPU_SET(bonk, &set);      // set cpu 0 
	sched_setaffinity(getpid(), sizeof(cpu_set_t), &set);   
} 

void p_to_c (int * pid ,int *core) { 
	cpu_set_t set; 
	pid_t apid;
	apid=(pid_t)pid;
	CPU_ZERO(&set);        // clear cpu mask 
        int bonk; 
        bonk=*core; 
	CPU_SET(bonk, &set);      // set cpu 0 
	sched_setaffinity(getpid(), sizeof(cpu_set_t), &set);   
} 

/* 
#include <stdio.h> 
void main(){ 
int ic,pid; 
findcore(&ic); 
printf("%d\n",ic); 
ic=ic+1; 
forcecore(&ic); 
findcore(&ic); 
printf("%d\n",ic); 
scanf("%d %d",&pid,&ic);
p_to_c(&pid,&ic);
findcore(&ic); 
printf("%d\n",ic); 
} 
*/
