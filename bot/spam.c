//gcc -c -fPIC -I/opt/python/gcc/2.7.11/include/python2.7 spam.c
//gcc -shared spam.o -o spam.so

#include <Python.h>
static PyObject *
spam_system(PyObject *self, PyObject *args)
{
    const char *command;
    int sts;

    if (!PyArg_ParseTuple(args, "s", &command))
        return NULL;
    sts = system(command);
    return Py_BuildValue("i", sts);
}

static PyMethodDef SpamMethods[] = {
    {"spam_system",  spam_system, METH_VARARGS, "Execute a shell command."},
//    {"x2i",  spam_x2i, METH_VARARGS, "x2"},
//    {"x2l",  spam_x2l, METH_VARARGS, "x2"},
//    {"x2d",  spam_x2d, METH_VARARGS, "x2"},
//    {"x2f",  spam_x2f, METH_VARARGS, "x2"},
//    {"x2s",  spam_x2s, METH_VARARGS, "x2"},
//    {"x2str",  spam_x2str, METH_VARARGS, "x2"},
    {NULL, NULL, 0, NULL}        /* Sentinel */
};

#if PY_VERSION_HEX >= 0x03000000

/* Python 3.x code */

static struct PyModuleDef spammodule = {
   PyModuleDef_HEAD_INIT,
   "spam",   /* name of module */
   "spam_doc", /* module documentation, may be NULL */
   -1,       /* size of per-interpreter state of the module,
                or -1 if the module keeps state in global variables. */
   SpamMethods
};

PyMODINIT_FUNC
PyInit_spam(void)
{
    PyObject *m, *d;
    PyObject *tmp;
    m = PyModule_Create(&spammodule);
    if (m == NULL)
        return NULL;
    d = PyModule_GetDict(m);
    tmp = Py_BuildValue("i",12345);
    PyDict_SetItemString(d,   "SPAM_WORLD", tmp);  Py_DECREF(tmp);  
    return m;
}

#else

/* Python 2.x code */

PyMODINIT_FUNC
initspam(void)
{
    (void) Py_InitModule("spam", SpamMethods);
}

#endif
