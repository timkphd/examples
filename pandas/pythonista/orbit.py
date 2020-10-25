# Motion control demo
from scene import *
from math import sin,pi
import time

def getpos(vec,t,dt,ts):
	t=t*ts
	t=t % 6.35
	j=int(round(t/dt))
	k= j % len(vec)
	return vec[k]

df=open("full","r")
lines=df.readlines()
dt=float(lines[0])
np=int(lines[1])
x={}
for i in range(0,np):
   x[i]=[]

nt=(len(lines)-2)/(np+2)
lnum=3
for j in range(0,int(nt)):
   for i in range(0,np):
#        print lnum,i
       data=lines[lnum]
       data=data.split()
       xdat=float(data[1])
       ydat=float(data[2])
       x[i].append([xdat,ydat])
       lnum=lnum+1
   lnum=lnum+2
#for i in range(0,100):
#    t=i*0.33
#    x0=getpos(x[0],t,dt)
#    x1=getpos(x[1],t,dt)
#    x2=getpos(x[2],t,dt)
#    print t,x0,x1,x2

class MyScene (Scene):
   def setup(self):
       self.x = self.size.w * 0.5
       self.y = self.size.h * 0.5
       self.j=time.time()
       self.ts=2.0
       
       
   def draw(self):
       background(.75,.75,.75)
       #import photos
       #all_assets = photos.get_assets()
       #last_asset = all_assets[-1]
       #img = last_asset.get_image()
       #img.show()
       #self.load_image(img)
       #return
       fill(1, 0, 0)
       self.x = min(self.size.w - 100, max(0, self.x))
       self.y = min(self.size.h - 100, max(0, self.y))
       t=time.time()-self.j
       x0=getpos(x[0],t,dt,self.ts)
       scale=100
       size=20
       self.x=self.size.w/2.0+scale*x0[0]
       self.y=self.size.h/2.0+scale*x0[1]
       ellipse(self.x, self.y, size,size)
       fill(0,1,0)
       x1=getpos(x[1],t,dt,self.ts)
       self.x=self.size.w/2.0+scale*x1[0]
       self.y=self.size.h/2.0+scale*x1[1]
       rect(self.x, self.y, size,size)
       fill(0,0,1)
       x2=getpos(x[2],t,dt,self.ts)
       self.x=self.size.w/2.0+scale*x2[0]
       self.y=self.size.h/2.0+scale*x2[1]
       ellipse(self.x, self.y, size,size)
   def touch_ended(self, touch):
   	self.ts=self.ts-0.1
   	if self.ts < 0.0  :
   		self.ts=1.0
run(MyScene())
