#!/usr/bin/python

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Button
from board import *
import sys
hole=7
if len(sys.argv) > 1:
    hole=int(sys.argv[1])
fill=[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
fill[hole]=0
boards=doit(fill)
boards.reverse()
ax = plt.subplot(111)
plt.subplots_adjust(bottom=0.2)
plt.axis([-0.1,1.1,-0.6,0.6])
x=list(range(0,15))
y=list(range(0,15))
x[0]=0.0+.5
y[0]=0.0
y[0]=y[0]-1.0
y[0]=y[0]*0.5
k=0
for irow in range(1,5):
    for jcol in range(-irow,irow+1,2) :
            k=k+1
            y[k]=irow*0.2
            y[k]=2.0*y[k]-1.0
            x[k]=jcol*0.1+.5
            y[k]=y[k]*0.5
#l, = plt.plot(x,y,linestyle="none",marker="*")
plt.plot(x,y,linestyle="none",marker='o',color="blue",markersize=14)
plt.plot(x,y,linestyle="none",marker='o',color="white",markersize=8)


newx=[]
newy=[]
j=0
for b in boards[0] :
    if b == 1 :
        newx.append(x[j])
        newy.append(y[j])
    j=j+1
m, = plt.plot(newx,newy,linestyle="none",marker="o",color="red",markersize=10)

class Index:
    ind = 0
    def next(self, event):
        self.ind += 1
        i = self.ind % 14
#        l.set_data(x[0:15-i],y[0:15-i])
        newx=[]
        newy=[]
        j=0
        for b in boards[i] :
            if b == 1 :
                newx.append(x[j])
                newy.append(y[j])
            j=j+1
#        m.set_data(x[0:15-i],y[0:15-i])
        m.set_data(newx,newy)
        plt.draw()
#        print("next\n")

    def prev(self, event):
        self.ind -= 1
        i = self.ind % 14
#        l.set_data(x[0:15-i],y[0:15-i])
        newx=[]
        newy=[]
        j=0
        for b in boards[i] :
            if b == 1 :
                newx.append(x[j])
                newy.append(y[j])
            j=j+1
#        m.set_data(x[0:15-i],y[0:15-i])
        m.set_data(newx,newy)
        plt.draw()

callback = Index()
axprev = plt.axes([0.7, 0.05, 0.1, 0.075])
axnext = plt.axes([0.81, 0.05, 0.1, 0.075])
bnext = Button(axnext, 'Next')
bnext.on_clicked(callback.next)
bprev = Button(axprev, 'Previous')
bprev.on_clicked(callback.prev)

plt.show()


