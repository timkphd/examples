#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <inttypes.h>
#include <stdio.h>
#include "../malloc_count.c"
#include "../stack_count.c"

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


static PyObject * pyspam_stack_count_clear(PyObject *self, PyObject *args)
{
    size_t gotit;
    void* base = stack_count_clear();
    gotit=(long)base;
    return PyLong_FromLong((long)gotit);
}

static PyObject * pystack_count_usage(PyObject *self, PyObject *args)
{
    size_t gotit;
    long lastbase;
    if (!PyArg_ParseTuple(args, "l", &lastbase))
        return NULL;
    void* base = (void*)lastbase;
    gotit=stack_count_usage(base);
    //printf("gotit= %ld\n",(long)gotit);
    return PyLong_FromLong((long)gotit);
}


static PyObject * pycurrent(PyObject *self, PyObject *args)
{
    size_t gotit;
    gotit=malloc_count_current();
    //printf("gotit= %ld\n",(long)gotit);
    return PyLong_FromLong((long)gotit);
}

static PyObject * pypeak(PyObject *self, PyObject *args)
{
    size_t gotit;
    gotit=malloc_count_peak();
    //printf("gotit= %ld\n",(long)gotit);
    return PyLong_FromLong((long)gotit);
}

static PyObject * pyreset(PyObject *self, PyObject *args)
{
    size_t gotit;
    malloc_count_reset_peak();
    gotit=0;
    return PyLong_FromLong((long)gotit);
}


// Py_INCREF(Py_None);
// return Py_None;

static PyMethodDef SpamMethods[] = {
    {"stack_count_clear",  pyspam_stack_count_clear, METH_VARARGS,"'clear' the stack by writing a sentinel value into it"},
    {"stack_count_usage",  pystack_count_usage, METH_VARARGS,"checks the maximum usage of the stack since the last clear call"},
    {"current",  pycurrent, METH_VARARGS,"returns the currently allocated amount of memory."},
    {"peak",  pypeak, METH_VARARGS,"returns the current peak memory allocation"},
    {"reset",  pyreset, METH_VARARGS,"resets the peak memory allocation to current"},
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

#ifdef JUNK
#PYTHON_START
# LD_PRELOAD=spam.cpython-38-x86_64-linux-gnu.so python
import spam

def loop2(base,n):
	z=""
	for i in range(1,10000):
		z=z+"1234"
	y=spam.stack_count_usage(base)
	x=spam.current()
	print("stack inside %d %d %d %d "%(x,y,n,base))
	n=n+1
	if(n < 10):
		loop2(base,n)
		y=spam.stack_count_usage(base)
		x=spam.current()
		print("unwinding %d %d %d %d" % (x,y,n,base))

base=spam.stack_count_clear()
loop2(base,0)
#PYTHON_END
#endif

