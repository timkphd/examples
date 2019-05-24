#***********************************************************************
#*    LICENSED MATERIALS - PROPERTY OF IBM                             *
#*    "RESTRICTED MATERIALS OF IBM"                                    *
#*                                                                     *
#*    5765-G18                                                         *
#*    5765-ESL                                                         *
#*    5765-EL5                                                         *
#*                                                                     *
#*    (C) COPYRIGHT IBM CORP. 2013, 2015.                              *
#*                                                                     *
#*    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION       *
#*    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH       *
#*    IBM CORP.                                                        *
#***********************************************************************
#
# To run the sample programs, xlf_r must be in your execution path or you must
# specify the full path where xlf_r is located.
#PATH:=$(PATH):/opt/ibm/xlf/15.1.2/bin
#PATH:=$(PATH):/opt/ibmhpc/pecurrent/base/bin
#
#
#
#  add rule for making mod files
.SUFFIXES:  .mod

#
# Compilers and such
#

FORT=mpfort -compiler /bin/xlf_r
LINK=mpfort -compiler /bin/xlf_r
#FORT=mpif90
#LINK=mpif90
#FORT=mpfort -compiler gnu
#LINK=mpfort -compiler gnu
#FORT=/software/apps/xl-15.1.2/mvapich2/2.2b/bin/mpif90
#LINK=/software/apps/xl-15.1.2/mvapich2/2.2b/bin/mpif90
XLF=xlf_r -c

LDFLAGS =  $(libs) $(LIB)
FCOPT = -O3 -qstrict -C -qsource -qxref -qattr $(INCLUDE)

# default for include and lib directories

INCLUDE= -I/opt/ibmmath/pessl/5.2/include64
LIB=
libs= -lesslsmp -lpesslmpich -lblacsmpich -lxlsmp

## DISTRIBUTED DATA samples

# OBJS lists objects used in the diffusion program
#
OBJS = main.o scalemod.o param.o diffusion.o fourier.o 

BASEOBJS = broadcast.o create.o delete.o init.o scatter_gather.o \
           pdata.o northsouth.o eastwest.o index.o

UTILOBJS = $(BASEOBJS) cdata.o putilities.o

UTILLIB = libputils.a

LIBOBJS = $(UTILLIB)(broadcast.o) $(UTILLIB)(create.o) \
          $(UTILLIB)(delete.o) $(UTILLIB)(init.o)      \
          $(UTILLIB)(scatter_gather.o) $(UTILLIB)(pdata.o)      \
          $(UTILLIB)(northsouth.o) $(UTILLIB)(eastwest.o)      \
          $(UTILLIB)(index.o) $(UTILLIB)(cdata.o)      \
          $(UTILLIB)(putilities.o)

distribute: diffusion pdgexmp image simple

#
#  Rule for building diffusion program
diffusion:	$(OBJS)
	$(LINK) -o diffusion $(OBJS) $(libs) $(LIB)

pdgexmp:  pdgexmp.o  $(UTILLIB)
	$(LINK) -o pdgexmp pdgexmp.o  -L . -lputils $(LDFLAGS)

image:  image.o  $(UTILLIB)
	$(LINK) -o image image.o -L . -lputils $(LDFLAGS)

simple:  simple.o  $(UTILLIB)
	$(LINK) -o simple simple.o  -L . -lputils $(LDFLAGS)

#rule to create the library

$(UTILLIB): $(LIBOBJS)
	ar rv $(UTILLIB) $%

# rules to create library objects

init.o: init.f pdata.o
	$(XLF) $(FFLAGS) init.f

exchange.o: init.f pdata.o
	$(XLF) $(FFLAGS) exchange.f

cdata.o: cdata.f pdata.o
	$(XLF) $(FFLAGS) cdata.f

create.o: create.f pdata.o
	$(XLF) $(FFLAGS) create.f

broadcast.o: broadcast.f pdata.o
	$(XLF) $(FFLAGS) broadcast.f

delete.o: delete.f pdata.o
	$(XLF) $(FFLAGS) delete.f

scatter_gather.o: scatter_gather.f pdata.o
	$(XLF) $(FFLAGS) scatter_gather.f

putilities.o: putilities.f $(BASEOBJS) cdata.o
	$(XLF) $(FFLAGS) putilities.f

eastwest.o: eastwest.f pdata.o
	$(XLF) $(FFLAGS) eastwest.f

northsouth.o: northsouth.f pdata.o
	$(XLF) $(FFLAGS) northsouth.f

$(UTILLIB)(broadcast.o): broadcast.o
	ar rv $(UTILLIB) $%

$(UTILLIB)(create.o): create.o
	ar rv $(UTILLIB) $%

$(UTILLIB)(delete.o): delete.o
	ar rv $(UTILLIB) $%

$(UTILLIB)(init.o): init.o
	ar rv $(UTILLIB) $%

$(UTILLIB)(scatter_gather.o): scatter_gather.o
	ar rv $(UTILLIB) $%

$(UTILLIB)(pdata.o): pdata.o
	ar rv $(UTILLIB) $%

$(UTILLIB)(northsouth.o): northsouth.o
	ar rv $(UTILLIB) $%

$(UTILLIB)(eastwest.o): eastwest.o
	ar rv $(UTILLIB) $%

$(UTILLIB)(index.o): index.o
	ar rv $(UTILLIB) $%

$(UTILLIB)(cdata.o): cdata.o
	ar rv $(UTILLIB) $%

$(UTILLIB)(putilities.o): putilities.o
	ar rv $(UTILLIB) $%

#
#  List of object dependencies for distributed data sample.
main.o: main.f scalemod.o param.o  diffusion.o fourier.o
diffusion.o: diffusion.f scalemod.o param.o
fourier.o: fourier.f diffusion.o scalemod.o param.o
scalemod.o: scalemod.f param.o
param.o: param.f
pdgexmp.o: pdgexmp.f $(UTILLIB)
simple.o: simple.f $(UTILLIB)
image.o: image.f $(UTILLIB)


##  SPARSE MATRIX samples

# HBOBJS and PARTOBJS list objects used in the SPARSE programs.
#
HBOBJS=read_mat.o mat_dist.o desym.o
PARTOBJS= part_block.o  partbcyc.o partrand.o

sparse: hb_sample pde90 pde77

pde90: pde90.o part_block.o
	$(LINK) $(LDFLAGS)  pde90.o part_block.o -o pde90



pde77: pde77.o  part_block.o
	$(LINK) $(LDFLAGS)  pde77.o  part_block.o -o pde77

hb_sample: $(HBOBJS) hb_sample.o $(PARTOBJS)
	$(LINK) $(LDFLAGS)  hb_sample.o -o hb_sample \
	$(HBOBJS) $(PARTOBJS)     

#
#  List of object dependencies for sparse matrix sample.
$(HBOBJS) hb_sample.o: read_mat.mod mat_dist.mod  part_bcyc.mod partrand.mod
part_bcyc.mod: partbcyc.o

#
#  Rule to clean executable and program
cleanall:
	rm -f *.lst *.o *.mod diffusion core image pdgexmp simple hb_sample pde90 pde77 libputils.a *out *list

#
clean: 
	/bin/rm -f *.o *.mod *.lst

#
# definitions for compiles
.f.mod:
	$(FORT) $(INCLUDE) $(FCOPT) -c $<
.f.o:
	$(FORT) $(INCLUDE) $(FCOPT)  -c  $<


