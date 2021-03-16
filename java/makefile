### export MODULEPATH=/nopt/nrel/apps/modules/test/modulefiles:$MODULEPATH
### ml openmpi/4.1.0-gcc-8.4.0/gcc-8.4.0-j15cd ex

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
  JAVA_HOME=/nopt/nrel/apps/openmpi/4.1.0-gcc-8.4.0-j15/jdk-15.0.2
  JAVA_OS=linux
  LINK_ARGS=-shared -o libutil.so -Wl,-soname,util
endif

ifeq ($(UNAME), Darwin)
  JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-15.0.2.jdk/Contents/Home
  JAVA_OS=darwin
  LINK_ARGS=-dynamiclib -fPIC  -o  libutil.dylib
endif

default: lib

headers: 
	javac ex/Util.java
	javac -h ex ex/Util.java

lib: headers
	gcc -fPIC -c ex_Util.c -I $(JAVA_HOME)/include -I ex -I $(JAVA_HOME)/include/$(JAVA_OS)
	gcc ex_Util.o $(LINK_ARGS)

test:lib
	java Test.java


clean:
	rm -rf ex/*h ex/*class
	rm -rf libutil.dylib ex_Util.o libutil.so

backup: clean
	tar -cf dojavac.tar ex  ex_Util.c  makefile  Test.java


