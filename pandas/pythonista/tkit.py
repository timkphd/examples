from board import *
from tkinter import *
window = Tk()
window.title("my stuff")
window.mainloop()

import tkinter
import time

hole=7

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
for board in boards:
    print(board)

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
  Window = tkinter.Tk()
  Window.title("Python Guides")

  Window.geometry(f'{Window_Width}x{Window_Height}')
  return Window
 

def create_animation_canvas(Window):
  canvas = tkinter.Canvas(Window)
  canvas.configure(bg="Blue")
  canvas.pack(fill="both", expand=True)
  return canvas
 

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
  
  ball = canvas.create_oval(Ball_Start_XPosition-Ball_Radius,
            Ball_Start_YPosition-Ball_Radius,
            Ball_Start_XPosition+Ball_Radius,
            Ball_Start_YPosition+Ball_Radius,
            fill="Red", outline="Black", width=4)
  ib=0
  togreen=True
  while True:
    canvas.move(ball,xinc,yinc)
    Window.update()
    time.sleep(Refresh_Sec)
    ball_pos = canvas.coords(ball)
    # unpack array to variables
    al,bl,ar,br = ball_pos
    if al < abs(xinc) or ar > Window_Width-abs(xinc):
      xinc = -xinc
    if bl < abs(yinc) or br > Window_Height-abs(yinc):
      yinc = -yinc
      state=boards[ib]
      ib=ib+1
      if(ib > 13): ib=0
      peg=0
      for io in state:
          if(io == 0 ):
              canvas.itemconfig(balls[peg],fill="white")
          else:
              canvas.itemconfig(balls[ib],fill="green")
          peg=peg+1     
 

Animation_Window = create_animation_window()
Animation_canvas = create_animation_canvas(Animation_Window)
animate_ball(Animation_Window,Animation_canvas, Ball_min_movement, Ball_min_movement)