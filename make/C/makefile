# this is our final product
nbody:

OBJS=correct_step.o evolve_step.o get_snapshot.o put_snapshot.o write_diagnostics.o \
evolve.o get_acc_jerk_pot_coll.o main.o predict_step.o read_options.o

# all of our object files are dependent on the headers.h file
# also, we make add a dependency on the makefile so if it gets
# changed we do a rebuild.
$(OBJS) : headers.h makefile

# our compiler and optimization settings
OPT= -O3 -g
CC= g++ $(OPT)

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
	rm -rf nbody $(OBJS)
