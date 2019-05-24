PURE=atomic invertc noatomic private schedule singleSubsectionc sortc \
commonInModMaintain2 critical invertf notype singleSubsectionf task \
withOUTcrit commonMaintain module omp_fft sortf withcrit withprivate \
ranmod

default:  $(PURE)

.SUFFIXES: .f90

PCC=mpicc
COPT=-O3 -fopenmp -lm
PFC=mpif90
FC=ifort
FOPT=-O3 -fopenmp -free

.f90:
	$(FC) $(FOPT) $< -o $@

.c:
	$(CC) $(COPT) $< -o $@

clean:
	rm -rf *mod   $(PURE) *out*


