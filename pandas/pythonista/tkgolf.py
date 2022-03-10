#!/usr/bin/env python3
from board import *
from tkinter import *
#import tkinter
import time

hole=1

info=False

global master
def show_values():
    global hole
    global master
    if info : print (w1.get())
    hole=int(w1.get())
    master.destroy()

def bye():
    quit()

master = Tk()
master.title('Select Open Hole 1-15')
master.geometry('300x100')
w1 = Scale(master, from_=1, to=15,orient = HORIZONTAL)
w1.pack()
b1=Button(master, text='Go', command=show_values,fg = "green").pack()
b2=Button(master, text='Exit', command=bye,bg = "purple", fg = "Red").pack()
b2

mainloop()


global boards
global did_boards
global tnow
did_boards=False
def setpin():
	global boards
	global did_boards
	global tnow
	global hole
	hole=int(hole)-1
	filled=[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	filled[hole]=0
	boards=doit(filled)
	boards.reverse()
	did_boards=True
	tnow=time.time()

setpin()
if info :
    for board in boards:
        print(board)
    print()

Window_Width=600

Window_Height=600

Ball_Start_XPosition = 50

Ball_Start_YPosition = 50

Ball_Radius = 30

Ball_min_movement = 5

Refresh_Sec = 0.01

xc=list(range(0,15))
yc=list(range(0,15))


def dodat(scale,xoff,yoff):
	k=0
	xc[0]=0.0+.5
	yc[0]=0.0
	yc[0]=yc[0]-1.0
	yc[0]=yc[0]*0.5
	k=0
	scale=scale*2.5
	for irow in range(1,5):
  	  for jcol in range(-irow,irow+1,2) :
  	  	k=k+1
  	  	yc[k]=irow*0.2
  	  	yc[k]=2.0*yc[k]-1.0
  	  	xc[k]=jcol*0.1+.5
  	  	yc[k]=yc[k]*0.5
  	  	xc[k]=xc[k]*scale
  	  	yc[k]=yc[k]*scale
	xc[0]=xc[0]*scale
	yc[0]=yc[0]*scale
	dx=xc[4]-xoff
	dy=yc[4]-yoff
	for i in range(0,15):
		xc[i]=xc[i]-dx
		yc[i]=yc[i]-dy

 

def create_animation_window():
  Window = Tk()
  Window.title("Golf Tee")

  Window.geometry(f'{Window_Width}x{Window_Height}')
  return Window
 

def create_animation_canvas(Window):
  canvas = Canvas(Window)
  canvas.configure(bg="khaki")
  canvas.pack(fill="both", expand=True)
  return canvas

def diffs(a,b):
    thelen=len(a)
    gone=[]
    for s1,s2,peg in zip(a,b,range(0,thelen)) :
        if (s1 != s2): 
           if(s1 == 1): dest=peg
           if(s1 == 0): gone.append(peg)
    if dest > gone[1] :
        source=gone[0]
        removed=gone[1]
    else:
        source=gone[1]
        removed=gone[0]
    if info : print("source=",source," dest=",dest, "removed=",removed)  
    return(source,dest)  

def path(x0,x1,y0,y1,t0,t1,t) :
	mx=(x0-x1)/(t0-t1)
	bx=x0-mx*t0
	my=(y0-y1)/(t0-t1)
	by=y0-my*t0
	x=mx*t+bx
	y=my*t+by
	return [x,y]


global t1 
t1=time.time()

def go(x):
    global t1
    t2=time.time()
    if t2 - t1 > x:
        t1=t2
        return True
    else:
        return False
        
def animate_ball(Window, canvas,xinc,yinc):
  dodat(Window_Width/3,Window_Width,Window_Height)
  balls=[]
  for ib in range(0,15):
    xc[ib]=xc[ib]-Window_Width/2
    yc[ib]=yc[ib]-Window_Height/2
    balls.append( canvas.create_oval(xc[ib]-Ball_Radius,
            yc[ib]-Ball_Radius,
            xc[ib]+Ball_Radius,
            yc[ib]+Ball_Radius,
            fill="green", outline="Black", width=4))
  
  ib=0
  togreen=True
  doing=True
  tstart=time.time()
  ic=0

  while doing:
    Window.update()
    #time.sleep(Refresh_Sec)
    if go(2) :
        state=boards[ib]
        if(ib > 0): 
            (s,t)=diffs(state,boards[ib-1])
            canvas.itemconfig(balls[s],fill="white")
            canvas.itemconfig(balls[t],fill="Yellow")
            ball=canvas.create_oval(xc[s]-Ball_Radius,
            yc[s]-Ball_Radius,
            xc[s]+Ball_Radius,
            yc[s]+Ball_Radius,
            fill="LightGreen", outline="Black", width=4)
            dx=xc[s]-xc[t]
            dy=yc[s]-yc[t]
            dx=-dx/50
            dy=-dy/50
            for it in range(0,50) :
                canvas.move(ball,dx,dy)
                Window.update()
                time.sleep(0.01)
            time.sleep(0.1)
            canvas.itemconfig(balls[s],fill="white")
            canvas.delete(ball)
            Window.update()

            nope="""
            """

        ib=ib+1
        if(ib > 13): 
              ib=0
              ic=ic+1
        peg=0
        for io in state:
            if(io == 0 ):
                canvas.itemconfig(balls[peg],fill="white")
            else:
                canvas.itemconfig(balls[peg],fill="green")
            peg=peg+1
        
            
    if ic == 2 and ib == 1 : 
        doing = False
        time.sleep(5)


Animation_Window = create_animation_window()
Animation_canvas = create_animation_canvas(Animation_Window)
animate_ball(Animation_Window,Animation_canvas, Ball_min_movement/.95, Ball_min_movement)




