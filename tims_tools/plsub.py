#!/usr/bin/env python3
import sys
from pylab import *
from matplotlib.pyplot import gcf
from matplotlib.ticker import AutoMinorLocator

import math
import warnings
import time
import os


def asaig(saveit=False):
    import matplotlib.pyplot as plt
    import numpy as np

    # Data for plotting
    t = np.arange(0.0, 2.0, 0.01)
    s = 1 + np.sin(2 * np.pi * t)

    fig, ax = plt.subplots()
    ax.plot(t, s)

    ax.set(xlabel='time (s)', ylabel='voltage (mV)',
           title='About as simple as it gets, folks')
    ax.grid()

    if saveit:
        fig.savefig("test.png")
    plt.show()


htext = """
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

BATCH MODE:

for v in abi default eight intel8 intel9 nine oneapi ; do
ls -lt ${v}_o.on ${v}_x.on 
batchplt.py ${v}_o.on ${v}_x.on <<INPUT
Message Size (Bytes)
Rate (Bytes/Sec.)
Bandwidth Comparison
both
auto
auto
n
1,1
2
INPUT
sleep 1
done



# in jupyter notebook

import sys
%matplotlib inline
sys.path.append("/Users/tkaiser2/bin")
from plsub import myplot
myplot
sets=[[[1,2,3,4],[1,4,9,16],"square"],[[1,2,3],[1,16,27],"qube"]]
myplot(sets=sets,topl="hello",doxkcd=True)

"""


def myplot(ismain=False, files=["dummy_file_name"], bl="x axis", sl="y axis", topl="title", do_log="none", xr="auto", yr="auto", do_sym="n", width="1", doxkcd=False, sets=None, outname=None, showit=True, subgrid="-1,-1"):
    # sets=[[[1,2,3,4],[1,4,9,16],"square"],[[1,2,3],[1,16,27],"qube"]]
    global htext
    if len(sys.argv) > 1:
        if (sys.argv[1] == "--help" or sys.argv[1] == "-help" or sys.argv[1] == "-h"):
            htext = htext.replace("CMD", sys.argv[0])
            print(htext)
            exit()

    warnings.simplefilter("ignore")
    if ismain:
        def AskFileForOpen(message="file="):
            fstring = input(message)
            return fstring

        def AskString(message="input:", default=""):
            prompt = message+": "+default+" "
            fstring = input(prompt)
            if (len(fstring) == 0):
                fstring = default
            return fstring

    def dummy():
        lines = []
        for x in range(0, 101):
            xin = x*2*math.pi/100.0
            yin = math.sin(xin)*math.cos(xin)
            aline = str(xin)+" "+str(yin)
            lines.append(aline)
        return (lines)

    paths = []
    if (ismain):
        if len(sys.argv) > 1:
            for pathname in sys.argv[1:]:
                #        print pathname
                paths.append(pathname)
        else:
            pathname = " "
            while pathname:
                pathname = AskFileForOpen(message='File to plot:')
                if pathname:
                    #            print pathname
                    paths.append(pathname)
    else:
        paths = files
    ip = len(paths)
    bottom = " "
    side = " "
    top = " "
    myout = None
    if (ismain):
        bottom = AskString("bottom label", "x axis")
        side = AskString("side label", "y axis")
        top = AskString("title", "the title")
        log = AskString("log", "none")
        xrange = "auto"
        yrange = "auto"
        xrange = AskString("X-range", xrange)
        yrange = AskString("Y-range", yrange)
        dosym = AskString("Do Symbols", "n")
        subgrid = AskString("subgrid", "-1,-1")
        dosym = (dosym == "y")
        lw = 1
        lw = AskString("lw", "1")
        lw = float(lw)
        showit = True
        if (sys.argv[0].find("batch")> -1): showit=False
    else:
        bottom = bl
        side = sl
        top = topl
        log = do_log
        xrange = xr
        yrange = yr
        dosym = do_sym
        dosym = (dosym == "y")
        lw = width
        myout = outname
    xray = {}
    yray = {}
    i = 0
    subgrid = subgrid.split(",")
    if len(subgrid) > 1:
        try:
            subx = int(subgrid[0])
            suby = int(subgrid[1])
        except:
            subx = -1
            suby = -1
    else:
        subx = -1
        suby = -1

    dosmall = False
    # even just calling xkcd breaks grid lins.
    # however there is something else surpressing  them
    if doxkcd:
        try:
            xkcd(False)
        except:
            pass
    if (sys.argv[0].find("xkcd") > 0 or ((ismain == False) and doxkcd == True)):
        try:
            # If the name of the program contains xkcd, that is we do a link
            # lrwxr-xr-x  1 tkaiser  staff  6 Aug 24 09:10 plxkcd -> plplot
            # then plots will be in the https://xkcd.com style.
            xkcd()
            dosmall = True
        except:
            print("xkcd not found")
    kplot = -1
    for pathname in paths:
        kplot = kplot+1
        try:
            f = open(pathname)
            lines = f.readlines()
            f.close()
        except:
            lines = dummy()
            paths[kplot] = "sin(x)*cos(x)"

        a = []
        b = []
        for line in lines:
            try:
                data = line.split()
                x = float(data[0])
                y = float(data[1])
                a.append(x)
                b.append(y)
            except:
                break
        xray[i] = a
        yray[i] = b
        i = i+1
    if (sets != None):
        i = 0
        xray = {}
        yray = {}
        for s in sets:
            xray[i] = s[0]
            yray[i] = s[1]
            i = i+1

    doxl = False
    doyl = False
    if (log.find("x") > -1 or log.find("X") > -1 or log.find("both") > -1 or log.find("Both") > -1):
        xscale("log")
        doxl = True
    if (log.find("y") > -1 or log.find("Y") > -1 or log.find("both") > -1 or log.find("Both") > -1):
        yscale("log")
        doyl = True

    leg = []
    sym = ['+', 'o', '*', 'x', 'X', '+', 'O']
    leggs = False
    #if (ismain):
    #    leggs = AskFileForOpen("Legend file:")
    if (leggs):
        f = open(leggs)
        for p in paths:
            p = f.readline()
            p = p.strip()
            leg.append(p)
    else:
        for p in paths:
            p = p.split("/")
            leg.append(p[len(p)-1])
    isym = 0
    if (sets != None):
        leg = []
        ip = len(sets)
        for s in sets:
            try:
                leg.append(s[2])
            except:
                pass
    # asaig()
    # return()
    if doxl == False and doyl == False:
        fig, ax = subplots()

    for myplot in range(0, ip):
        if (dosym):
            if (lw == 0):
                plot(xray[myplot], yray[myplot], sym[isym], linewidth=lw)
            else:
                sym[isym] = sym[isym]+"-"
                # print(sym[isym])
                plot(xray[myplot], yray[myplot], sym[isym], linewidth=lw)
        else:
            plot(xray[myplot], yray[myplot], linewidth=lw)
        isym = isym+1
    # asaig()
    # return()

    if (len(leg) > 0):
        legend(leg, loc=0)
    if (xrange != "auto"):
        if type(xrange) == type("str"):
            xrange = xrange.replace(",", " ")
            xrange = xrange.replace(":", " ")
            xrange = xrange.strip()
            xmin, xmax = xrange.split()
            xmin = float(xmin)
            xmax = float(xmax)
            xlim(xmin, xmax)
        else:
            xticks = xrange[2]
            xmin = float(xrange[0])
            xmax = float(xrange[1])
            xlim(xmin, xmax)
            # if doxl == False and doyl == False :
            #    ax.xaxis.set_ticks(xticks)

    if (yrange != "auto"):
        if type(yrange) == type("str"):
            yrange = yrange.replace(",", " ")
            yrange = yrange.replace(":", " ")
            yrange = yrange.strip()
            ymin, ymax = yrange.split()
            ymin = float(ymin)
            ymax = float(ymax)
            ylim(ymin, ymax)
        else:
            yticks = yrange[2]
            ymin = float(yrange[0])
            ymax = float(yrange[1])
            ylim(ymin, ymax)
            # if doxl == False and doyl == False :
            #    ax.yaxis.set_ticks(yticks)

    if dosmall:
        xlabel(bottom, fontsize='x-small')
        ylabel(side, fontsize='x-small')
        # this does not work
        params = {
            'xtick.labelsize': '2',
            'ytick.labelsize': '2'}
        rcParams.update(params)
    else:
        params = {
            'xtick.labelsize': '10',
            'ytick.labelsize': '10'}
        # rcParams.update(params)
        xlabel(bottom)
        ylabel(side)
    title(top)
    # ax.xaxis.set_minor_locator(MultipleLocator(5))
    myax = "none"
    if subx > 0:
        try:
            ax.xaxis.set_minor_locator(AutoMinorLocator(subx))
        except:
            pass
        myax = "x"

    if suby > 0:
        try:
            ax.yaxis.set_minor_locator(AutoMinorLocator(suby))
        except:
            pass
        myax = "y"
    if subx > 0 and suby > 0:
        myax = "both"
    if myax != "none":
        grid(visible=True, which='both', axis=myax)

    x = time.localtime()
    stime = ("%2.2d%2.2d%2.2d%2.2d%2.2d%2.2d" %
             (x[0]-2000, x[1], x[2], x[3], x[4], x[5]))
    if myout != None:
        stime = myout
    dsave = os.getenv("HOME")+"/plot"
    if os.path.isdir(dsave) == False:
        dsave = "."
    sfile = dsave+"/"+stime+".pdf"
    didsave = False
    didshow = False
    fig = gcf()
    (w, h) = fig.get_size_inches()
    ar = [11.0, 8.5]
    scale = 0.75
    ar[0] = ar[0]*scale
    ar[1] = ar[1]*scale
    # fig.set_size_inches(11.0,8.5)

    fig.set_size_inches(ar[0], ar[1])
    # fig.savefig('test2png.png', dpi=100)

    try:
        if myout != "none":
            savefig(sfile)
            didsave = True
    except:
        print("save to ", sfile, " failed.")
        pass
    host = os.getenv("HOSTNAME")
    # who=os.getlogin()
    # print who+"@"+host+":"+sfile
    fig.set_size_inches(w, h)
    try:
        if showit:
            show()
            didshow = True
    except:
        pass
    if (didsave):
        print("saved to:", sfile, " displayed:", didshow)
    else:
        print("saved:", didsave, " displayed:", didshow)
    fig = None
    ax = None


if __name__ == '__main__':
    myplot(True)
