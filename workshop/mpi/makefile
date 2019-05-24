PF77 = mpif77 
PF90 = mpif90 
PCC  = mpicc 
all: cexam fexam

CEXES= c_ex00 c_ex01 c_ex02 c_ex03 c_ex04 c_ex05 c_ex06 \
       c_ex07 c_ex08 c_ex09 c_ex10 c_ex11 c_ex12 c_ex13 \
       helloc workerwaspc
	
FEXES= f_ex00 f_ex01 f_ex02 f_ex03 f_ex04 f_ex05 f_ex06 \
       f_ex07 f_ex08 f_ex09 f_ex10 f_ex11 f_ex12 f_ex13 \
       hellof workerwaspf testall2all

.SUFFIXES: .f .f90

#pgi
FFLAG=-Mfree 
#intel
FFLAG= -FR

cexam: $(CEXES)

fexam: $(FEXES)

mpi.o: mpi.f
	$(PF77) -c mpi.f
	
.f90:
	$(PF90) $(FFLAG) $< -o $@

.f:
	$(PF77) $(FFLAG) $< -o $@

.c:
	$(PCC) $(CFLAG) $< -o $@


clean:
	rm -f *mod  $(CEXES) $(FEXES) *.err *.out f*o


tar: clean
	rm -f mpi.tar
	tar --exclude .svn -cf mpi.tar *

