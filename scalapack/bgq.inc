CFLAGS=-DNOUNDER
PFC=mpixlf90_r
PCC=mpixlc_r
LIBS=-L$(LAPACK_ROOT)/lib64 -L$(ESSL_ROOT)/lib64 -L$(SCALAPACK_ROOT)/lib64 -llapack -lscalapack -lblas -llapack -lblas -lscalapack
FLIBS=-L/opt/ibmcmp/xlf/bg/14.1/lib64 -lxlopt -lxl -lxlf90 -lxlfmath
