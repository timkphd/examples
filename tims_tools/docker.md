### recipe file
```
tkaiser2-37907s:~ tkaiser2$ cat SIMPLEDOC
FROM ubuntu:latest
#### Specifications
#### OS: Ubuntu latest
#


#ARG JVERSION=https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.5-linux-x86_64.tar.gz
ARG JVERSION=https://julialang-s3.julialang.org/bin/linux/aarch64/1.10/julia-1.10.5-linux-aarch64.tar.gz
ARG JPATH=/nopt/apps/julia/julia-1.10.5/bin:
#ARG JPATH=/nopt/apps/julia/julia-1.10.5/julia-1.10.5/bin


# ENV DEBIAN_FRONTEND=noninteractive

### Install Packages and Libraries ###


#RUN rm -r /var/lib/apt/lists
#RUN mkdir -p /var/lib/apt/lists/partial
RUN apt-get update
RUN apt-get install -y ca-certificates

RUN apt  --allow-unauthenticated -y  upgrade
RUN apt  --allow-unauthenticated -y  update
## Compilers and Fetchers
#RUN apt-get --allow-unauthenticated  update -y 
RUN apt install -y wget 
RUN apt-get install -y git 
RUN apt-get install -y ca-certificates 
RUN apt-get install -y libssl-dev
RUN apt-get install -y build-essential cmake gfortran vim nano emacs
RUN mkdir -p /extra01
RUN mkdir -p /extra02
RUN mkdir -p /extra03
RUN mkdir -p /extra04 
RUN chmod 777 /extra*



## Python, pip
RUN apt-get install python3 -y
RUN apt install python3.12-venv -y
RUN mkdir -p /nopt/apps/python
RUN python3 -m venv /nopt/apps/python
# install pip this way due to https://github.com/pypa/setuptools/issues/3269
RUN wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py && /nopt/apps/python/bin/python get-pip.py && rm get-pip.py 

RUN mkdir /nopt/apps/julia

#This install the binary version of julia
RUN cd /nopt/apps/julia && wget --no-check-certificate $JVERSION && tar zxvf julia-1.10.5-*gz

#or...
#Build julia from source.
#RUN cd /nopt/apps/julia && wget --no-check-certificate https://github.com/JuliaLang/julia/archive/refs/tags/v1.10.5.tar.gz && tar xfx v1.10.5.tar.gz && rm v1.10.5.tar.gz
#RUN cd /nopt/apps/julia/julia-1.10.5 && export JULIA_SSL_NO_VERIFY_HOSTS=github.com && make install


RUN cd /nopt/apps && git clone https://github.com/timkphd/examples.git
COPY SIMPLEDOC /nopt/apps/DOCKERFILE


ENV PATH=/nopt/apps/python/bin:$JPATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:


## LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/lib:/usr/lib64:/usr/local/lib:/usr/local/lib64:

USER ubuntu


```
### build the container
```
docker build . -f SIMPLEDOC -t macm1 
```
### start the continer
```
tkaiser2-37907s:openmp tkaiser2$ docker run -it --mount type=bind,source="$(pwd)",target=/extra01 macm1

```
### build Fortran and C codes
```

ubuntu@2dbd3bea6053:/extra01$ gfortran -fopenmp -O3 invertf.f90 -o f_con
ubuntu@2dbd3bea6053:/extra01$ gcc -fopenmp -O3 invertc.c -o c_con
```

### BTW... these source codes are also in the container:

```
uubuntu@ba579a41ec25:~$ ls -l /nopt/apps/examples/openmp/{invertc.c,invertf.f90}
-rw-r--r-- 1 root root 5934 Sep 10 18:17 /nopt/apps/examples/openmp/invertc.c
-rw-r--r-- 1 root root 5004 Sep 10 18:17 /nopt/apps/examples/openmp/invertf.f90
ubuntu@ba579a41ec25:~$ 
```

### run with 4 threads 
```
ubuntu@2dbd3bea6053:/extra01$ export OMP_NUM_THREADS=4
ubuntu@2dbd3bea6053:/extra01$ ./f_con
section    1 start time=      0.0000     end time=     0.80000     error=    0.78532E-08
section    2 start time=      0.0000     end time=     0.78900     error=    0.36763E-08
section    3 start time=      0.0000     end time=     0.78800     error=    0.71402E-08
section    4 start time=      0.0000     end time=     0.79900     error=    0.64280E-08
ubuntu@2dbd3bea6053:/extra01$ ./c_con
section 1 start time= 0.00033188   end time=    0.52552  error= 7.8532e-09
section 2 start time= 0.00033188   end time=    0.52575  error= 3.67633e-09
section 3 start time= 0.00033188   end time=    0.52256  error= 7.14024e-09
section 4 start time= 0.00033689   end time=    0.52274  error= 6.42803e-09
ubuntu@2dbd3bea6053:/extra01$ 
ubuntu@2dbd3bea6053:/extra01$ 
```
### exit container
```
ubuntu@2dbd3bea6053:/extra01$ 
ubuntu@2dbd3bea6053:/extra01$ exit
exit
```
### build and run native
```
tkaiser2-37907s:openmp tkaiser2$ gfortran -fopenmp -O3 invertf.f90 -o f_nat
tkaiser2-37907s:openmp tkaiser2$  gcc -fopenmp -O3 invertc.c -o c_nat
tkaiser2-37907s:openmp tkaiser2$ export OMP_NUM_THREADS=4
tkaiser2-37907s:openmp tkaiser2$ ./f_nat
section    1 start time=     0.30000E-02 end time=     0.66900     error=    0.78532E-08
section    2 start time=     0.30000E-02 end time=     0.67000     error=    0.36763E-08
section    3 start time=     0.30000E-02 end time=     0.66900     error=    0.71402E-08
section    4 start time=     0.30000E-02 end time=     0.55600     error=    0.64280E-08
tkaiser2-37907s:openmp tkaiser2$ ./c_nat
section 1 start time= 0.00058413   end time=    0.62851  error= 7.8532e-09
section 2 start time= 0.00058508   end time=    0.62779  error= 3.67633e-09
section 3 start time= 0.00059009   end time=    0.62989  error= 7.14024e-09
section 4 start time= 0.00059319   end time=    0.58018  error= 6.42803e-09

```


### where docker keeps its stuff
```
tkaiser2-37907s:Containers tkaiser2$ ls /Users/tkaiser2/Library/Containers/com.docker.docker/
Data  backend.lock  hypervisor.error.json  volume-backup-schedule.json
tkaiser2-37907s:Containers tkaiser2$ ls ~/.docker
buildx	cli-plugins  config.json  contexts  daemon.json  desktop-build	mutagen  run
tkaiser2-37907s:Containers tkaiser2$ 
```
