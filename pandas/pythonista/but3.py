# Motion control demo
from scene import *
#from math import sin,pi
import time
import console
from board import *
import sys
hole=7
kb=0
forward=False
if len(sys.argv) > 1:
    hole=int(sys.argv[1])
console.clear()
hole=console.input_alert("Golf Tee Game","Enter an open hole (1-15)","1")
hole=int(hole)
filled=[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
filled[hole]=0
boards=doit(filled)
boards.reverse()
#print(boards)
xc=list(range(0,15))
yc=list(range(0,15))
scale=600
size=50
tnow=time.time()
tswipe=0.0
tmove=0.3
def dodat(scale,xoff,yoff):
	k=0
	xc[0]=0.0+.5
	yc[0]=0.0
	yc[0]=yc[0]-1.0
	yc[0]=yc[0]*0.5
	k=0
	for irow in range(1,5):
  	  for jcol in range(-irow,irow+1,2) :
  	  	k=k+1
  	  	yc[k]=irow*0.2
  	  	yc[k]=2.0*yc[k]-1.0
  	  	xc[k]=jcol*0.1+.5
  	  	yc[k]=yc[k]*0.5
  	  	xc[k]=xc[k]*scale+xoff
  	  	xc[k]=xc[k]
  	  	yc[k]=yc[k]*scale+yoff
	xc[0]=xc[0]*scale+xoff
	yc[0]=yc[0]*scale+yoff
	for k in range(1,15):
		xc[k]=xc[k]-0.25*xc[0]
	xc[0]=xoff/2
	
	for k in range(0,15) :
		xc[k]=xc[k]*2-xc[0]+xoff/2
	xc[0]=xc[4]
	         
def path(x0,x1,y0,y1,t0,t1,t) :
	mx=(x0-x1)/(t0-t1)
	bx=x0-mx*t0
	my=(y0-y1)/(t0-t1)
	by=y0-my*t0
	x=mx*t+bx
	y=my*t+by
	return [x,y]
	
	
class MyScene (Scene):
   def setup(self):
       self.x = self.size.w * 0.5
       self.y = self.size.h * 0.5
       self.j=time.time()
       self.ts=2.0
       self.tswipe=0
       self.move=[]
       dodat(self.x/2,self.x,self.y)
       self.start=self.size.w
#       print(self.size)
       self.kb=kb
       self.dis=0
       self.tstart=time.time()
#       background(1,0,1)
       
   def draw(self):
       background(.55,.55,.65)
       movet=1.0
       if self.start != self.size.w:
       	self.setup()
       fill(1, 1, 1)
#       print(self.x,self.y)
       for i,j in zip(xc,yc):
       	ellipse(i,j,.5*size,.5*size)
       fill(1,0,1)
       if (time.time()-movet > self.tstart):
       	khole=0
       	for i,j in zip(xc,yc):
       		if boards[self.kb][khole]==1 :
       			ellipse(i+(0.25-0.1)*size,j+(0.25-0.1)*size,0.2*size,0.2*size)
       		khole=khole+1
       	dt=time.time()-self.tswipe
       	if dt < tmove and len(self.move) == 3:
       		fill(1,0,1)
       		x1=xc[self.move[0]]
       		y1=yc[self.move[0]]
       		x2=xc[self.move[2]]
       		y2=yc[self.move[2]]
       		xm=xc[self.move[1]]
       		ym=yc[self.move[1]]
       		ellipse(xm+(0.25-0.1)*size,ym+(0.25-0.1)*size,0.2*size,0.2*size)
       		fill(1,1,1)
       		ellipse(x2+(0.25-0.1)*size,y2+(0.25-0.1)*size,0.2*size,0.2*size)
       		fill(0,1,0)
       		xt,yt=path(x1,x2,y1,y2,0,tmove,dt)
       		ellipse(xt+0.15*size,yt+0.15*size,0.25*size,0.25*size)
       		#print(x1,y1)
       	else:
       		pass
       		#print(time.time()-self.tswipe,tmove)
       else:
       	khole=0
       	for i,j in zip(xc,yc):
       		if boards[self.kb][khole]==1 :
       			xt,yt=path(khole*self.x/15.,i+(0.25-0.1*size),khole*self.y/15.,j+(0.25-0.1)*size,self.tstart,self.tstart+movet,time.time())
       			ellipse(xt,yt,0.2*size,0.2*size)
       			#print(xt,yt)
       		khole=khole+1

       			

   def touch_ended(self, touch):
       lx=touch.location[0]
       ly=touch.location[1]
       newdis=(lx*lx+ly*ly)
       previous=self.kb
       if newdis > self.dis:
         self.kb=self.kb+1
       else :
       	  self.kb=self.kb-1
       if self.kb == 14 :
         self.kb=0
       if self.kb < 0 :
       	 self.kb=13
       if (self.kb > previous):
       	forward=True
       	self.tswipe=time.time()
       	self.move=getmove(boards[previous],boards[self.kb])
#       	print(forward,self.tswipe)
       	

   def touch_began(self,touch):
     #print("start",touch.location)
     lx=touch.location[0]
     ly=touch.location[1]
     self.dis=(lx*lx+ly*ly)
run(MyScene())
