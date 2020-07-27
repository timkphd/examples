# this is our final product
nbody:

LIB=correct_step.o evolve_step.o get_snapshot.o put_snapshot.o write_diagnostics.o \
evolve.o get_acc_jerk_pot_coll.o  predict_step.o read_options.o

OBJS=$(LIB) main.o



# all of our object files are dependent on the headers.h file
# also, we make add a dependency on the makefile so if it gets
# changed we do a rebuild.
$(LIB) main.o : headers.h makefile

# our compiler and optimization settings
OPT= -O3 -g -fpic
CC= g++

# we are building files that end in .C
.SUFFIXES: .C

# here is how we build files that end in .C
.C.o:
	$(CC) $(OPT) -c $<
	
# our final build command
nbody: $(OBJS)
	$(CC) $(OPT) $(OBJS) -o nbody

# clean everything up
clean:
	rm -rf nbody $(OBJS) lib* nbody.shar nbody.stat
	
STATCLIB: $(LIB)
	$(AR) cr libnb.a $(LIB)

nbody.stat:STATCLIB main.o
	$(CC) main.o -L. -lnb -o nbody.stat

SHARLIB: $(LIB)
	mkdir ./lib
	$(CC) -shared -o ./lib/libnbs.so $(LIB)

nbody.shar:SHARLIB main.o
	$(CC) main.o -L./lib -lnbs -o nbody.shar
	
all: nbody nbody.shar nbody.stat
