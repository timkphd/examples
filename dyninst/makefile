export DINC=$(DBASE)/include
export BINC=$(BBASE)/include
export IINC=$(IBASE)/include

export DLIB=$(DBASE)/lib
export BLIB=$(BBASE)/lib
export ILIB=$(IBASE)/lib

all: trace_tool libtracelib.so extra
	
trace_tool:tracetool.cpp
	g++ -g tracetool.cpp $(EXFLAGS) -L$(DLIB) -ldyninstAPI -lpcontrol -lpatchAPI -linstructionAPI  -lcommon -I$(DINC)  -Wno-deprecated-declarations  -L$(BLIB) -lboost_filesystem -I$(BINC) -I$(IINC) -o trace_tool

libtracelib.so: tracelib.cpp
	g++ -c -fPIC tracelib.cpp
	g++ -shared tracelib.o -o libtracelib.so

extra: inverts.c extra.cpp
	g++ -g inverts.c -DPRINT -DINVERT -DDOE extra.cpp -o extra

run:all
	. ./runit
 
clean:
	rm -rf tracelib.o libtracelib.so extra trace_tool
