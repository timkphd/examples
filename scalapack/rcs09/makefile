test: intel mic
# builds versions of the matrix inversion test programs
# some use the cula GPU library while some use other 
# more standard packages

# programs using the g95 or gfortran or nagfor compilers
# the *cuda programs link against the cula library
cuda1: fourd nrf nrf.cuda fourd.cuda wing.dat

#programs using the intel compilers or mkl
#see the LIBS settings below
intel: mklc mklf fourd.mkl fourd.intel wing.dat
mic: m_mklc m_mklf m_fourd.mkl wing.dat

#programs using the portland group compilers
pg: fourd.pg wing.dat

G95OPT=-fno-second-underscore
#all of these Fortran compilers work fine for cuda/cula programs
#note the option for the g95 compiler
FOR=g95 $(G95OPT)
FOR=gfortran
FOR=nagfor

#location of version 10 and 11 of MKL.  Use
#one or the other.  These will change in
#the future.  
LIBPATH=/opt/intel/mkl/10.0.1.014/lib/em64t
LIBPATH=/opt/intel/Compiler/11.0/081/mkl/lib/em64t
LIBPATH=/opt/intel/Compiler/11.1/069/mkl/lib/em64t
#LIBPATH=/opt/intel/Compiler/11.1/076/Frameworks/mkl/lib/em64t
LIBPATH=/software/development/intel/composer_xe_2013.1.117/mkl/lib/intel64
M_LIBPATH=/software/development/intel/composer_xe_2013.1.117/mkl/lib/intel64
LIBPATH=$(MKLROOT)lib/intel64
M_LIBPATH=$(MKLROOT)lib/intel64

#There is a bug in the Intel 10 compiler that
#prevents psgesv.f90 from working correctly at
#optimization greater than -O1
OPT=-O1

#For Intel dynamic linking use the next setting for LIBS.
#You will need to set your LD_LIBRARY_PATH environmental
#variable to point to LIBPATH or you might get an error
#message about "cannot open shared object file"
LIBS= \
  -L$(LIBPATH) \
  -lmkl_scalapack_lp64 \
  -lmkl_intel_lp64 \
  -lmkl_blacs_openmpi_lp64 \
  -lmkl_sequential \
  -lmkl_core \
  -lpthread

#For Intel static linking use the next line for LIBS.
LIBS= \
  $(LIBPATH)/libmkl_scalapack_lp64.a \
  $(LIBPATH)/libmkl_intel_lp64.a \
  $(LIBPATH)/libmkl_blacs_openmpi_lp64.a \
  $(LIBPATH)/libmkl_core.a  \
  $(LIBPATH)/libmkl_sequential.a \
  $(LIBPATH)/libmkl_core.a  \
  $(LIBPATH)/libmkl_sequential.a \
  $(LIBPATH)/libmkl_core.a  \
  -lpthread

LIBS=-mkl

#mac don't include the parallel stuff
LIBSM= \
  $(LIBPATH)/libmkl_intel_lp64.a \
  $(LIBPATH)/libmkl_sequential.a \
  $(LIBPATH)/libmkl_core.a  \
  -lpthread

#various versions of the Portland Group Libraries
LIBSPG= -L/opt/pgi/osx86-64/9.0/lib -llapack -lblas
LIBSPG= -L/opt/pgi/linux86-64/9.0-4/lib  -llapack -lblas
LIBSPG= -L/opt/pgi/linux86-64/10.0/lib  -llapack -lblas

FCULA=-lcula_core -lcula_lapack -lcublas -lcudart
CULAMODS=/opt/development/gpu/current/cula/include/cula_status.f90 /opt/development/gpu/current/cula/include/cula_lapack.f90

wing.dat: airfoil.py
	chmod 700 airfoil.py
	./airfoil.py 2000

mklc: mkl.c 
	icc -o mklc mkl.c $(LIBS)

mklf: mkl.f 
	ifort -o mklf mkl.f $(LIBS)

fourd.mkl:fourd.f90
	ifort   -O3 -o fourd.mkl fourd.f90  $(LIBS)

m_mklc: mkl.c 
	icc -o m_mklc mkl.c $(LIBS) -mmic

m_mklf: mkl.f 
	ifort -o m_mklf mkl.f $(LIBS) -mmic

m_fourd.mkl:fourd.f90
	ifort   -O3 -o m_fourd.mkl fourd.f90  $(LIBS) -mmic

dofit:dofit.f90
	ifort   -O3 -o dofit dofit.f90  $(LIBS)

fourd.pg:fourd.f90
	pgf90 -O3 -o fourd.pg fourd.f90  $(LIBSPG)

fourd:fourd.f90 cgesvnag.o
	$(FOR) -O3 -o fourd fourd.f90  cgesvnag.o

fourd.intel:fourd.f90 cgesvintel.o
	ifort -O3 -o fourd.intel fourd.f90  cgesvintel.o

cgesv.o:cgesv.f90
	$(FOR) -O3 -c cgesv.f90

cgesvgnu.o:cgesv.f90
	$(FOR) -O3 -o cgesvgnu.o  -c cgesv.f90

cgesvnag.o:cgesv.f90
	$(FOR) -O3 -o cgesvnag.o  -c cgesv.f90

cgesvintel.o:cgesv.f90
	ifort -O3 -o cgesvintel.o  -c cgesv.f90

nrf: nrf.f90
	$(FOR) -O3 nrf.f90 -o nrf

nrf.cuda: nrfcuda.f90
	$(FOR) $(CULAMODS) nrfcuda.f90 -O3 -I$(CULA_ROOT)/include -L$(CULA_ROOT)/lib64 $(FCULA) -o nrf.cuda

fourd.cuda: fourdcu.f90 cgesvgnu.o
	$(FOR) $(CULAMODS) fourdcu.f90 -O3 cgesvgnu.o -I$(CULA_ROOT)/include -L$(CULA_ROOT)/lib64 $(FCULA) -o fourd.cuda

clean:
	rm -f fourd.mkl fourd fourd.pg nrf mklc mklf *.o *mod out.dat wing.dat a.out nrf.cuda fourd.cuda fourd.intel

tar:
	tar -czf agm129.tgz airfoil.py cgesv.f90 cudaonly.f90 do2 do3 doit dopg false fourdcu.f90 fourd.f90 \
	                    makefile mkl.c mkl.f nrfcuda.f90 nrf.f90 Readme results small source.dat true 
