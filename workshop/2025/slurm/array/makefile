all:invertc input

invertc:invertc.c
	gcc -O3 -fopenmp invertc.c -o invertc

# Our python program creates a file in_list that
# contains 100 lines of input, one for each run
# and a diredctory "inputs" that contains 100
# subdirectories each with an input file. The
# file dir_list contains a list of the directories

input:setarray.py 
	rm -rf in_list dir_list inputs
	./setarray.py 100

clean:
	rm -rf invertc in_list dir_list inputs slurm*out `find . -type d | grep "/"`

backup:
	tar -czf array.tgz bot doit doboth invertc.c invertp.py makefile setarray.py tymer useboth usedirs uselist

