#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <inttypes.h>
#include <stdio.h>


#include <sys/types.h> 
#include <unistd.h> 
#include <sched.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <stdio.h> 
#include <assert.h> 

/*
// returns the currently allocated amount of memory 
extern size_t malloc_count_current(void);

// returns the current peak memory allocation 
extern size_t malloc_count_peak(void);

// resets the peak memory allocation to current 
extern void malloc_count_reset_peak(void);

// "clear" the stack by writing a sentinel value into it.
void* stack_count_clear(void)

//checks the maximum usage of the stack since the last clear call.
size_t stack_count_usage(void* lastbase)
*/

pid_t getpid(void); 

void FORCECORE (int *core) { 
    int bonk; 
	cpu_set_t set; 
    bonk=*core; 
	CPU_ZERO(&set);        // clear cpu mask 
	CPU_SET(bonk, &set);      // set cpu 0 
	sched_setaffinity(getpid(), sizeof(cpu_set_t), &set);   
} 

void FINDCORE (int *ic) 
{ 
    ic[0] = sched_getcpu(); 
} 


void P_TO_C (int * pid ,int *core) { 
	int bonk;
	cpu_set_t set; 
	pid_t p;
    bonk=*core; 
	CPU_ZERO(&set);        // clear cpu mask 
	CPU_SET(bonk, &set);      // set cpu 0 
	p=(pid_t)*pid;	
	printf("not working %ld %d call from process\n",(long)p,bonk);
	sched_setaffinity(p, sizeof(cpu_set_t), &set);   
} 


static PyObject * findcore(PyObject *self, PyObject *args)
{
    size_t gotit;
    int core;
    FINDCORE(&core);
    gotit=(long)core;
    return PyLong_FromLong((long)gotit);
}

static PyObject * forcecore(PyObject *self, PyObject *args)
{
    size_t gotit;
    long lastbase;
    int core;
    if (!PyArg_ParseTuple(args, "l", &lastbase))
        return NULL;
    core=(int)lastbase;
    FORCECORE(&core);
    gotit=0;
    return PyLong_FromLong((long)gotit);
}


static PyObject * p_to_c(PyObject *self, PyObject *args)
{
    size_t id,p;
    size_t gotit;

    int pid,core;
    if (!PyArg_ParseTuple(args, "ll", &id,&p))
        return NULL;
    pid=(int)id;
    core=(int)p;
    P_TO_C(&pid,&core);
    gotit=0;
    //printf("gotit= %ld\n",(long)gotit);
    return PyLong_FromLong((long)gotit);
}



// Py_INCREF(Py_None);
// return Py_None;

static PyMethodDef SpamMethods[] = {
    {"findcore",  findcore, METH_VARARGS,"Find the core on which calling task is running"},
    {"forcecore",  forcecore, METH_VARARGS,"Force calling task to a core"},
    {"p_to_c",  p_to_c, METH_VARARGS,"Force task to core"},
    {NULL, NULL, 0, NULL}        /* Sentinel */
};

static struct PyModuleDef spammodule = {
    PyModuleDef_HEAD_INIT,
    "spam",   /* name of module */
    NULL, /* module documentation, may be NULL */
    -1,       /* size of per-interpreter state of the module,
                 or -1 if the module keeps state in global variables. */
    SpamMethods
};

PyMODINIT_FUNC
PyInit_spam(void)
{
    return PyModule_Create(&spammodule);
}


