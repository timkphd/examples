PURE=StomOmpf_00a StomOmpf_00b StomOmpf_00c StomOmpf_00d StomOmpf_00e StomOmpf_00f StomOmpf_00g
HYBRID=invertf StomOmpc_02 phostname tsort short StomOmpf_02a StomOmpf_02d
default: $(PURE) $(HYBRID)

.SUFFIXES: .f .f90

PCC=mpicc
COPT=-O3 -fopenmp 
PFC=mpif90
FC=ifort
FOPT=-O3 -fopenmp -free

.f:
	$(FC) $(FOPT) $< -o $@

.c:
	$(PCC) $(COPT) $< -o $@

clean:
	rm -rf *mod  $(PURE) $(HYBRID) *out*


StomOmpf_02a:StomOmpf_02a.f
	$(PFC) $(FOPT) $< -o $@

StomOmpf_02d:StomOmpf_02d.f
	$(PFC) $(FOPT) $< -o $@

invertf:invertf.f
	$(PFC) $(FOPT) $< -o $@

tsort:tsort.f
	$(PFC) $(FOPT) $< -o $@

short:short.f
	$(PFC) $(FOPT) $< -o $@


