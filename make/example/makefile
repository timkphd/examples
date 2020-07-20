project1: data.o main.o io.o
	cc data.o main.o io.o -o project1

data.o: data.c data.h
	cc -c data.c

main.o: data.h io.h main.c
	cc -c main.c

io.o: io.h io.c
	cc -c io.c

clean:
	rm -rf data.o main.o io.o project1

