.SUFFIXES: .f90

#link line
L=gfortran -g -O3
#compile line
P=gfortran -g -c -O3

OBJ1= face.o          control.o       more.o          reproduce.o
OBJ2= fitness.o       linked.o        mutate.o        rest.o
OBJ3= galapagos.o     list_stuff.o    numz.o          sort_mod.o
OBJ4= global_test.o   map_stuff.o     ran_mod.o 
OBJS= $(OBJ1) $(OBJ2) $(OBJ3) $(OBJ4)

darwin: $(OBJS)
	$(L) -o darwin $(OBJS)

face.o: face.f90 galapagos.o numz.o sort_mod.o
	$(P) face.f90

fitness.o: fitness.f90 global_test.o list_stuff.o map_stuff.o numz.o
	$(P) fitness.f90

galapagos.o: galapagos.f90 numz.o
	$(P) galapagos.f90

control.o: control.f90 galapagos.o numz.o
	$(P) control.f90

linked.o:linked.f90 list_stuff.o
	$(P) linked.f90

list_stuff.o:list_stuff.f90
	$(P) list_stuff.f90

map_stuff.o: map_stuff.f90 global_test.o list_stuff.o
	$(P) map_stuff.f90

more.o: more.f90 control.o numz.o ran_mod.o
	$(P) more.f90

mutate.o: mutate.f90 control.o galapagos.o numz.o ran_mod.o
	$(P) mutate.f90

ran_mod.o: ran_mod.f90 numz.o
	$(P) ran_mod.f90

reproduce.o: reproduce.f90 control.o galapagos.o  numz.o ran_mod.o
	$(P) reproduce.f90

rest.o: rest.f90 control.o face.o list_stuff.o map_stuff.o numz.o sort_mod.o
	$(P) rest.f90

sort_mod.o: sort_mod.f90 galapagos.o
	$(P) sort_mod.f90

numz.o: numz.f90
	$(P) numz.f90

global_test.o: global_test.f90
	$(P) global_test.f90

archive: 
	tar -czf archive.tgz control.f90 face.f90 fitness.f90 fort.12 fort.13 galapagos.f90 \
	global_test.f90 linked.f90 list_stuff.f90 listing.html makefile map_stuff.f90 more.f90 \
	mutate.f90 numz.f90 ran_mod.f90 recent.f90 reproduce.f90 rest.f90 sort_mod.f90 
	
clean:
	rm  -f *.mod *.o darwin *dat

