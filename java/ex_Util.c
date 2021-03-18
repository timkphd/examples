#define _GNU_SOURCE 
#include <sys/types.h>
#include <unistd.h>
#include <sched.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <assert.h>

#include "ex_Util.h"

#ifdef __APPLE__
// not defined on Mac
int sched_getcpu() {
	return(12345);
}
#endif

JNIEXPORT jint JNICALL Java_ex_Util_getCore
  (JNIEnv *env, jclass cls)
{
      // char *name;
      int ic;
      ic=sched_getcpu();
      return ic;
      // name=malloc(10);
      // sprintf(name,"%d",ic);
      // return (*env)->NewStringUTF(env, name);
}


//void forcecore (int *core) { 
//see  https://github.com/OpenHFT/Java-Thread-Affinity.git
//for a complete example
JNIEXPORT void JNICALL Java_ex_Util_setCore
(JNIEnv *env, jobject obj, jint bonk)
{
	cpu_set_t set; 
	int ic;
        pid_t getpid(void); 
	CPU_ZERO(&set);        // clear cpu mask 
       // int bonk; 
       // bonk=*core; 
	CPU_SET(bonk, &set);      // set cpu 0 
	//sched_setaffinity(getpid(), sizeof(cpu_set_t), &set);   
	sched_setaffinity(0, sizeof(cpu_set_t), &set);   
        //sleep(2);
        ic=sched_getcpu();
} 


