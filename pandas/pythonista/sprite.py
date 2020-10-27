from scene import *
import speech
import random
import os
global plist
global ptr
global start_t
global warn
global people
global startdir
global doran
global first
global doblock
global lan1,lan2
from time import sleep
global hideit
hideit=True

first=[]
doran=False
doblock=True
getlist=open("words","r")
people=getlist.read()
people=people.split("\n")
if(len(people[-1])) < 2:
	people=people[0:len(people)-1]
#print(people)
people=[people[i] for i in range(len(people)-1,-1,-1)]
warn=[]
warn.append("Stop That! It Hurts!")
warn.append("Keep your hands to yourself.")
warn.append("Back off! lest I infect your laptop with a virus.")
#warn.append("Don't blame me I voted for Gary Johnson.")
warn.append("Did you get your computer in a cracker jack box?")
warn.append("How would you like it if I poked you?")
warn.append("I like snakes. I just put one in your bag")
warn.append("You must be one of those dos users my mother told me about.")
warn.append("Please give me your password so I can empty your bank account.")
warn.append("Don't blame me I voted for Ross Perot.")
warn.append("Are the only shirts you own from S C ?")
warn.append("I know Fortran, 66, Watt Four, 77, 90, 95, 2000, 2003, and 2008")
#print(warn)
import time

global pres
pres=-1

global whole

def getone():
	global startdir
	os.chdir(startdir)
#	print(people)
	for p in people:
		os.chdir(startdir+"/"+p+".dir")
		f=open("list","r")
		glist=f.readlines()
		glist=glist[0].strip()
		first.append(startdir+"/"+p+".dir/"+glist+".png")
#	print(first)
def startit():
	global plist
	global tlist
	global ptr
	global people
	global startdir
	global pres
	global doran
	global whole
	if doran:
		pres=int(random.random()*len(people))
	else:
		pres=pres+1
		if(pres >= len(people)):
			pres=0
	infile=people[pres]
#	print("running ",infile,pres)
	#pres=len(people)
	os.chdir(startdir)
	os.chdir(infile+".dir")
	whole=infile
	f=open("list","r")
	plist=f.readlines()
	ptr=0
	tlist=[]
	for p in plist:
		p=p.strip()
		f=open(p+".txt","r")
#		print(p+".txt")
		try:
			tlist.append(f.read())
		except:
			print("%s %s contains bad data" % (infile,p))

class MyScene (Scene):
    def setup(self):
        global hideit
        self.background_color = 'midnightblue'
        self.lastt=0.0
        self.pick=-1
        self.hide_close(hideit)
        
    def hide_close(self,state=True):
    	from objc_util import ObjCInstance
    	v=ObjCInstance(self.view)
    	for x in v.subviews() :
    		if str(x.description()).find('UIButton') >=0 :
    			x.setHidden(state)


    def touch_began(self, touch):
        global warn
        global doblock
        global pres
        global lan2
        global whole
        global hideit
        x, y = touch.location
        if hideit and abs(x-self.size.x) < 50 and (y < 50) :
            speech.say("exit")
            time.sleep(0.5)
            os.abort()
        #x,y=[10,10]
        if doblock:
        	dis=1e6
        	k=-1
        	ksave=-1
        	for c in self.children:
        		[px,py]=c.position
        		dx=(px-x)**2
        		dy=(py-y)**2
        		k=k+1
        		tdis=(dx+dy)**0.5
        		if tdis < dis:
        			dis=tdis
        			ksave=k
#        			print(ksave,dis)
        			doblock=False
        			pres=ksave-1
        	#print("final",dis,ksave)
        	while (len(self.children) > 0):
        		self.children[0].remove_from_parent()
        	startit()
        	return		
        move_action = Action.move_to(x, y, 0.7, TIMING_SINODIAL)
        self.s2.run_action(move_action)
        speech.stop()
        pick=int(random.random()*len(warn))
        while(pick == self.pick):
        	pick=int(random.random()*len(warn))
        self.pick=pick
        #speech.say(warn[pick],lan2)
        speech.say(whole)
        if (x < 50) and (y < 50):
        	doblock=True
        	while (len(self.children) > 0):
        		self.children[0].remove_from_parent()
        	#startit()
        
    def draw(self):
    	global start_t
    	global tlist,ptr,plist
    	global flist
    	global doblock
    	global lan1
    	if speech.is_speaking():
    		self.lastt=time.time()
    	else:		
    		if doblock :
    			if len(self.children) < 2:
    				
    				k=1
    				j=1
    				for t in first:
#    					print("t=",t,self.size)
    					self.s2=SpriteNode(t)
    					rat=self.size.y/self.s2.size.y
    					rat=rat*0.1
    					self.s2.size=self.s2.size*rat
    					self.s2.position=[self.size.x*k/9,self.size.y*j/5]
    					#self.s2.position[0]=200
    					#self.s2.position.y=self.size.y*random.random()
#    					print(self.s2.position)
    					k=k+1
    					if(k==8):
    						k=1
    						j=j+.75
    					self.add_child(self.s2)
    			return
    					
    		if ptr >= len(plist) and not(speech.is_speaking()) and time.time() > self.lastt+5.0 :
    			startit()
    		if ptr < len(plist) and time.time() > self.lastt+1.5:
    			self.s2=None
    			p=os.getcwd()+"/"+plist[ptr].strip()+".png"
#    			print(p)
    			self.s2=SpriteNode(p)
    			self.s2.position=self.size/2
    			rat=self.size.y/self.s2.size.y
    			self.s2.size=self.s2.size*rat
    			self.add_child(self.s2)
    			if ptr == 0 : sleep(2)
    			if (len(self.children) > 1) :
    				self.children[0].remove_from_parent()
#    			print(p,tlist[ptr])
    			speech.say(tlist[ptr],lan1)
    			ptr=ptr+1

startdir=os.getcwd()
#print(speech.get_languages())
lan1=speech.get_languages()[16]
lan2=speech.get_languages()[14]
getone()
startit()
import ui

run(MyScene())
