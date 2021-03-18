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

JNIEXPORT jstring JNICALL Java_ex_Util_getCore
  (JNIEnv *env, jclass cls)
{
      char *name;
      int ic;
      ic=sched_getcpu();
      name=malloc(10);
      sprintf(name,"%d",ic);
      return (*env)->NewStringUTF(env, name);
}

