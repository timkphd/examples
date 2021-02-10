#!/usr/bin/env python3
import sys
from pylab import *
import math
import warnings
import time
import os

htext="""
####################

CMD [file1 file2...]

####################

# Produces simple but nice X/Y plots.  

# Program will try to save plots to a "plots"
# subdirectory off of your home directory. It
# assumes it exists.

# It will ask for data files until you just enter
# return.  You can alternatively enter files on
# the command line.

# If you enter an input file that does not exist
# it will be replaced with the dummy data defined
# below.  You can "test" the program by using "-"
# as the file name and use the default values for
# all other inputs.

# If the name of the program contains the string
# "xkcd" plots will be done in the xkcd style. 
# See https://xkcd.com. You can have it both ways 
# by creating a symbolic link:
#
# ln -s plplot plxkcd 

# EasyDialogs is a Mac specific module. See: 
# https://documentation.help/Python-PEP/module-EasyDialogs.html
# It should be easy to replicate on most systems. 
# However, here we provide a simple "text" version.


# in jupyter notebook

import sys
%matplotlib inline
sys.path.append("/Users/tkaiser2/bin")
from plsub import myplot
myplot
sets=[[[1,2,3,4],[1,4,9,16],"square"],[[1,2,3],[1,16,27],"qube"]]
myplot(sets=sets,topl="hello",doxkcd=True)

"""

def myplot(ismain=False,files=["dummy_file_name"],bl="x axis",sl="y axis",topl="title",do_log="none",xr="auto",yr="auto",do_sym="n",width="1",doxkcd=False,sets=None):
#sets=[[[1,2,3,4],[1,4,9,16],"square"],[[1,2,3],[1,16,27],"qube"]]
    if len(sys.argv) > 1:
        if (sys.argv[1] == "--help" or sys.argv[1] == "-help" or sys.argv[1] == "-h"):
            htext=htext.replace("CMD",sys.argv[0])
            print(htext)
            exit()

    warnings.simplefilter("ignore")
    if ismain:
            def AskFileForOpen(message="file="):
                fstring=input(message)
                return fstring
            def AskString(message="input:",default=""):
                prompt=message+": "+default+" "
                fstring=input(prompt)
                if(len(fstring)==0):
                    fstring=default
                return fstring

    def dummy():
        lines=[]
        for x in range(0,101):
            xin=x*2*math.pi/100.0
            yin=math.sin(xin)*math.cos(xin)
            aline=str(xin)+" "+str(yin)
            lines.append(aline)
        return(lines)

    paths=[]
    if(ismain):
        if len(sys.argv) > 1:
            for pathname in sys.argv[1:]:
        #        print pathname
                paths.append(pathname)
        else:
            pathname=" "
            while pathname:
                pathname = AskFileForOpen(message='File to plot:')
                if pathname:
        #            print pathname
                    paths.append(pathname)
    else:
        paths=files
    ip=len(paths)
    bottom=" "
    side=" "
    top=" "
    if(ismain):
        bottom=AskString("bottom label","x axis")
        side=AskString("side label","y axis")
        top=AskString("title","the title")
        log=AskString("log","none")
        xrange="auto"
        yrange="auto"
        xrange=AskString("X-range",xrange)
        yrange=AskString("Y-range",yrange)
        dosym=AskString("Do Symbols","n")
        dosym=(dosym == "y")
        lw=1
        lw=AskString("lw","1")
        lw=float(lw)
    else:
        bottom=bl
        side=sl
        top=topl
        log=do_log
        xrange=xr
        yrange=yr
        dosym=do_sym
        dosym=(dosym == "y")
        lw=width
    xray={}
    yray={}
    i=0
    dosmall=False
    try:
        xkcd(False)
    except:
        pass
    if(sys.argv[0].find("xkcd")> 0 or ((ismain == False ) and doxkcd==True)):
        try:
            # If the name of the program contains xkcd, that is we do a link
            # lrwxr-xr-x  1 tkaiser  staff  6 Aug 24 09:10 plxkcd -> plplot
            # then plots will be in the https://xkcd.com style.
            xkcd()
            dosmall=True    
        except:
            print("xkcd not found")
    kplot=-1
    for pathname in paths:
        kplot=kplot+1
        try:
            f=open(pathname)
            lines=f.readlines()
            f.close()
        except:
            lines=dummy()
            paths[kplot]="sin(x)*cos(x)"

        a=[]
        b=[]
        for line in lines:
            try:
                data=line.split()
                x=float(data[0])
                y=float(data[1])
                a.append(x)
                b.append(y)
            except:
                break
        xray[i]=a
        yray[i]=b
        i=i+1
    if (sets != None):
        i=0
        xray={}
        yray={}
        for s in sets:
            xray[i]=s[0]
            yray[i]=s[1]
            i=i+1

    if(log.find("x") > -1 or  log.find("X") > -1 or log.find("both") > -1 or log.find("Both") > -1):
        xscale("log")
    if(log.find("y") > -1 or  log.find("Y") > -1 or log.find("both") > -1 or log.find("Both") > -1):
        yscale("log")

    leg=[]
    sym=['+','o','*','x','#','X','0']
    leggs=False
    if(ismain):leggs=AskFileForOpen("Legend file:")
    if(leggs):
        f=open(leggs)
        for p in paths:
            p=f.readline()
            p=p.strip()
            leg.append(p)
    else:
        for p in paths:
            p=p.split("/")
            leg.append(p[len(p)-1])
    isym=0
    if (sets != None):
        leg=[]
        ip=len(sets)
        for s in sets:
            leg.append(s[2])
    for myplot in range(0,ip) :
            if(dosym):
                if (lw == 0):
                    plot(xray[myplot], yray[myplot], sym[isym],linewidth=lw)
                else:
                    sym[isym]=sym[isym]+"-"
                    plot(xray[myplot], yray[myplot], sym[isym],linewidth=lw)
            else :
                plot(xray[myplot], yray[myplot], linewidth=lw)
            isym=isym+1
        
    if(len(leg) > 0):
        legend(leg,loc=0)
    if(xrange != "auto"):
        xrange=xrange.replace(","," ")
        xrange=xrange.replace(":"," ")
        xrange=xrange.strip()
        [xmin,xmax]=xrange.split()
        xmin=float(xmin)
        xmax=float(xmax)
        xlim(xmin,xmax)

    if(yrange != "auto"):
        yrange=yrange.replace(","," ")
        yrange=yrange.replace(":"," ")
        yrange=yrange.strip()
        [ymin,ymax]=yrange.split()
        ymin=float(ymin)
        ymax=float(ymax)
        ylim(ymin,ymax)
    
    if dosmall:
        xlabel(bottom,fontsize='x-small')
        ylabel(side,fontsize='x-small')
        # this does not work
        params = {
             'xtick.labelsize':'2',
             'ytick.labelsize':'2'}
        rcParams.update(params)
    else:
        params = {
             'xtick.labelsize':'10',
             'ytick.labelsize':'10'}
        rcParams.update(params)
        xlabel(bottom)
        ylabel(side)
    title(top)
    grid(True)
    x=time.localtime()
    stime=("%2.2d%2.2d%2.2d%2.2d%2.2d%2.2d" % (x[0]-2000,x[1],x[2],x[3],x[4],x[5]))
    stime=os.getenv("HOME")+"/plot/"+stime+".pdf"
    didsave=False
    didshow=False
    try:
        savefig(stime)
        didsave=True
    except:
        print("save to ",stime," failed.  Directory exists: ",os.path.isdir(os.getenv("HOME")+"/plot"),os.getenv("HOME")+"/plot")
        pass
    host=os.getenv("HOSTNAME")
    who=os.getlogin()
    #print who+"@"+host+":"+stime
    try:
        show()
        didshow=True
    except:
        pass
    if (didsave):
        print("saved to:",stime," displayed:",didshow)
    else :
        print("saved:",didsave," displayed:",didshow)



if __name__ == '__main__':
    myplot(True)

