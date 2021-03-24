#define _GNU_SOURCE 
#include <sys/types.h> 
#include <unistd.h> 
#include <sched.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <stdio.h> 
#include <assert.h> 
/* TO COMPILE: R CMD SHLIB mapit.c */
/* TO Make an a.out gcc -DDOMAIN mapiit.c */
int sched_getcpu(); 
#ifdef __APPLE__
/* currently dummy routines on APPLE see below for a starting point */
/* https://yyshen.github.io/2015/01/18/binding_threads_to_cores_osx.html */
#define SYSCTL_CORE_COUNT   "machdep.cpu.core_count"

typedef struct cpu_set {
  uint32_t    count;
} cpu_set_t;

static inline void
CPU_ZERO(cpu_set_t *cs) { cs->count = 0; }

static inline void
CPU_SET(int num, cpu_set_t *cs) { cs->count |= (1 << num); }

// static inline int CPU_ISSET(int num, cpu_set_t *cs) { return (cs->count & (1 << num)); }

int sched_getcpu() {
	return(0);
}
void sched_setaffinity(pid_t i, int thesize, cpu_set_t *set) {

}
#endif
void findcore (int *ic) 
{ 
    ic[0] = sched_getcpu(); 
} 
void forcecore_org (int *core) { 
	cpu_set_t set; 
	pid_t getpid(void); 
	CPU_ZERO(&set);        // clear cpu mask 
	int bonk; 
	bonk=*core; 
	CPU_SET(bonk, &set);      // set cpu 0 
	sched_setaffinity(getpid(), sizeof(cpu_set_t), &set);   
} 


void forcecore (int *core) { 
	int bonk; 
	pid_t getpid(void);
	cpu_set_t set; 
	bonk=*core; 
	bonk=abs(bonk) ;
	CPU_ZERO(&set);        // clear cpu mask 
	CPU_SET(bonk, &set);      // set cpu 0 
	if (*core < 0 ){
	 	sched_setaffinity(0, sizeof(cpu_set_t), &set);   
    }else{
	 	sched_setaffinity(getpid(), sizeof(cpu_set_t), &set);   
    }
} 


void p_to_c (int * pid ,int *core) { 
	cpu_set_t set; 
	pid_t apid;
        int i;
        int bonk; 
	CPU_ZERO(&set);        // clear cpu mask 
        bonk=*core; 
	CPU_SET(bonk, &set);      // set cpu 0 
	apid=(pid_t)*pid;
	i=sched_setaffinity(apid, sizeof(cpu_set_t), &set);   
        printf("%d %ld %d\n",i,apid,bonk);
} 

#ifdef DOMAIN
#include <stdio.h> 
void main(){ 
int ic,pid; 
findcore(&ic); 
printf("%d\n",ic); 
ic=ic+1; 
forcecore(&ic); 
findcore(&ic); 
printf("%d %d\n",getpid(),ic); 
scanf("%d %d",&pid,&ic);
p_to_c(&pid,&ic);
} 
#endif
