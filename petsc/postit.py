import os
import sys
get="ls -R */*/stdout | sort -n"
counts={}
files=os.popen(get,"r")
mydirs=files.readlines()
for x in mydirs:
    x=x.strip()
    y=x.split("/")
    c=int(y[0])*int(y[1])
    if counts.__contains__(c):
        mydir=counts[c]
        mydir.append(x)
        counts[c]=mydir
    else:
        counts[c]=[x]
#print(counts)
cores=list(counts.keys())
cores.sort()
#print(cores)
print("cores\ttasks\tthreads\terror\titerations\tmin\tmax\tave")
for c in cores:
    print(c)
    dirs=counts[c]
    for d in dirs:
        get="cat "+d+' | egrep "System 2|^min" | tail -2'
        files=os.popen(get,"r")
        results=files.readlines()
        results[0]=results[0].replace("Norm of error","\t")
        results[0]=results[0].replace("System 2: iterations","\t")
        results[1]=results[1].replace("max=","\t")
        results[1]=results[1].replace("min=","\t")
        results[1]=results[1].replace("ave=","\t")
        d=d.replace("/","\t")
        d=d.replace("stdout","")
        msng=d+results[0].strip()+"\t"+results[1].strip()
        ot=msng.split("\t")
        #print(int(ot[0]),int(ot[1]),float(ot[2]),int(ot[3]),float(ot[4]),float(ot[5]),float(ot[6]))
        print("\t{:3d}\t{:3d}\t{:10.3f}\t{:6d}\t{:10.4f}\t{:10.4f}\t{:10.4f}".format(int(ot[0]),int(ot[1]),float(ot[2]),int(ot[3]),float(ot[4]),float(ot[5]),float(ot[6])))
        #print("{:3d}\t{:3d}\t{0:6.2f}\t{:6d}\t{0:6.2f}\t{0:6.2f}\t{0:6.2f}".format(int(ot[0]),int(ot[1]),float(ot[2]),int(ot[3]),float(ot[4]),float(ot[5]),float(ot[6])))

