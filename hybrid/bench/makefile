#------------------------------------------------#
#                                                #
# Makefile for mixed mode Benchmark code.        #
#                                                #
# Set the FC and FFLAGS for you platform and     #
# then type 'make'.                              #
#------------------------------------------------#

include ${VERSION}
#--------------------------------------#
# Build rules                          #
#--------------------------------------#

EXE=	mixedModeBenchmark.$(END)

SRC=	parallelEnvironment.f90 \
	pt_to_pt_pingpong.f90 \
	pt_to_pt_pingping.f90 \
	pt_to_pt_multiPingpong.f90 \
	pt_to_pt_multiPingping.f90 \
	pt_to_pt_haloexchange.f90 \
	collective_barrier.f90 \
	collective_reduction.f90 \
	collective_broadcast.f90 \
	collective_scatterGather.f90 \
	collective_alltoall.f90 \
	mixedModeBenchmarkDriver.f90 \
	output.f90 \
	benchmarkSetup.f90

#
# No need to edit below this line
#

.SUFFIXES:
.SUFFIXES: .f90 .o

OBJ=	$(SRC:.f90=.o)

MOD=	$(SRC:.f90=.mod)
EDT=	$(SRC:.f90=.f90~)
TMP=	$(MOD) $(EDT) core

.f90.o:
	$(FC) $(FFLAGS) -c $<


all:	$(EXE)

$(EXE):	$(OBJ)
	$(FC) $(FFLAGS) -o $@ $(OBJ) $(LFLAGS)

$(OBJ):	$(MF)

clean:
	rm -f $(EXE) *.o *.mod $(EDT) 
#
# Do not delete this line, f90depend requires it
#

benchmarkSetup.o benchmarkSetup.mod : benchmarkSetup.f90 parallelEnvironment.mod
	$(FC) -c $(FFLAGS) benchmarkSetup.f90
mixedModeBenchmarkDriver.o  : mixedModeBenchmarkDriver.f90 pt_to_pt_pingpong.mod pt_to_pt_pingping.mod pt_to_pt_multipingpong.mod pt_to_pt_multipingping.mod pt_to_pt_haloexchange.mod collective_barrier.mod collective_reduction.mod collective_broadcast.mod collective_scatterGather.mod collective_alltoall.f90 parallelEnvironment.mod collective_alltoall.mod output.mod
	$(FC) -c $(FFLAGS) mixedModeBenchmarkDriver.f90
pt_to_pt_pingpong.o pt_to_pt_pingpong.mod : pt_to_pt_pingpong.f90 parallelEnvironment.mod benchmarkSetup.mod output.mod
	$(FC) -c $(FFLAGS) pt_to_pt_pingpong.f90
pt_to_pt_pingping.o pt_to_pt_pingping.mod : pt_to_pt_pingping.f90 parallelEnvironment.mod benchmarkSetup.mod output.mod
	$(FC) -c $(FFLAGS) pt_to_pt_pingping.f90
pt_to_pt_multiPingpong.o pt_to_pt_multiPingpong.mod : pt_to_pt_multiPingpong.f90 parallelEnvironment.mod benchmarkSetup.mod output.mod
	$(FC) -c $(FFLAGS) pt_to_pt_multiPingpong.f90
pt_to_pt_multiPingping.o pt_to_pt_multiPingping.mod : pt_to_pt_multiPingping.f90 parallelEnvironment.mod benchmarkSetup.mod output.mod
	$(FC) -c $(FFLAGS) pt_to_pt_multiPingping.f90
pt_to_pt_haloexchange.o pt_to_pt_haloexchange.mod : pt_to_pt_haloexchange.f90 parallelEnvironment.mod benchmarkSetup.mod output.mod
	$(FC) -c $(FFLAGS) pt_to_pt_haloexchange.f90
collective_barrier.o collective_barrier.mod : collective_barrier.f90 parallelEnvironment.mod benchmarkSetup.mod output.mod
	$(FC) -c $(FFLAGS) collective_barrier.f90
collective_reduction.o collective_reduction.mod : collective_reduction.f90 parallelEnvironment.mod benchmarkSetup.mod output.mod
	$(FC) -c $(FFLAGS) collective_reduction.f90
collective_broadcast.o collective_broadcast.mod : collective_broadcast.f90 parallelEnvironment.mod benchmarkSetup.mod output.mod
	$(FC) -c $(FFLAGS) collective_broadcast.f90
collective_scatterGather.o collective_scatterGather.mod : collective_scatterGather.f90 parallelEnvironment.mod benchmarkSetup.mod output.mod
	$(FC) -c $(FFLAGS) collective_scatterGather.f90
collective_alltoall.o collective_alltoall.mod : collective_alltoall.f90 parallelEnvironment.mod benchmarkSetup.mod output.mod
	$(FC) -c $(FFLAGS) collective_alltoall.f90
output.o output.mod : output.f90 benchmarkSetup.mod parallelEnvironment.mod
	$(FC) -c $(FFLAGS) output.f90
parallelEnvironment.o parallelEnvironment.mod : parallelEnvironment.f90
	$(FC) -c $(FFLAGS) parallelEnvironment.f90
