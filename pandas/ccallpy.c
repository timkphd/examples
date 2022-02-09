#include <Python.h>
#include <stdio.h>
#include <stdlib.h>
// https://www.linuxjournal.com/article/8497
// https://www.geeksforgeeks.org/default-arguments-in-python
// https://docs.python.org/3/extending/embedding.html?highlight=pytuple_new
// gcc -I/nopt/nrel/apps/210929a/level00/gcc-9.4.0/python-3.10.0/include/python3.10 ccallpy.c -L/nopt/nrel/apps/210929a/level00/gcc-9.4.0/python-3.10.0/lib -lpython3.10 -o ccallpy

void exec_pycode(const char* code)
{
  Py_Initialize();
  PyRun_SimpleString(code);
//Py_Finalize();
}

void process_expression(char* exp,int num, char* func_name)
{
    FILE*        exp_file;
    PyObject*    main_module, * global_dict, * expression;
    long out;
    PyObject *pArgs, *pValue ;

    // Initialize a global variable for
    // display of expression results
    PyRun_SimpleString("sx = 1234");

    // Open and execute the Python file
    exp_file = fopen(exp, "r");
    PyRun_SimpleFile(exp_file, exp);

    // Get a reference to the main module
    // and global dictionary
    main_module = PyImport_AddModule("__main__");
    global_dict = PyModule_GetDict(main_module);

    // Extract a reference to the function "func_name"
    // from the global dictionary
    expression =
        PyDict_GetItemString(global_dict, func_name);

    while(num--) {
        // Make a call to the function referenced
        // by "expression"
        pArgs = PyTuple_New(1);
        pValue = PyLong_FromLong(num);
        if (!pValue) {
	  fprintf(stderr, "Cannot convert argument\n");
	  return ;
        }
        PyTuple_SetItem(pArgs, 0, pValue);
        //out=PyLong_AsLong(PyObject_CallObject(expression, NULL));
        out=PyLong_AsLong(PyObject_CallObject(expression, pArgs));
	printf("out=%ld\n",out);
    }
    PyRun_SimpleString("print('sx defined earlier as: ',sx)");
}


int main(int argc, char **argv){
char* exp="exam.py";
char command[1024];
    FILE*        exp_file;

sprintf(command,"%s","\n\
import numpy as np    \n\
x=np.zeros([4,4])     \n\
print(x)             ");
printf("%s\n",command);

exec_pycode(command);

sprintf(command,"%s","  \n\
x=x+1                   \n\
x[0,0]=10               \n\
x[1,1]=20               \n\
x[2,2]=30               \n\
x[3,3]=40               \n\
print(np.linalg.inv(x)) ");
printf("%s\n",command);

exec_pycode(command);

exp_file = fopen(exp, "w");
fprintf(exp_file,"def func(i=2):\n  return(i*i+3)\n\n");
fclose(exp_file);
process_expression(exp,4,"func");
Py_Finalize();

return(0);
}

