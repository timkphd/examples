import sys
import ui
import time
from time import sleep
from scene import *
import speech
import random
import os
import sound
global plist
global ptr
global start_t
global warn
global people
global startdir
global doran
global first
global doblock
global lan1, lan2
global hideit
global wait
wait = 5
hideit = True
Alice = True
startdir = "bruce"
if len(sys.arg) > 1:
    startdir = sys.argv[1]
os.chdir(startdir)


class fart (object):
    location = (5, 5)


xy = fart()


first = []
doran = False
#doran = True
doblock = True
getlist = open("words", "r")
people = getlist.read()
people = people.split("\n")
if(len(people[-1])) < 2:
    people = people[0:len(people)-1]
# print(people)
#people = [people[i] for i in range(len(people)-1, -1, -1)]
warn = []
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
# print(warn)

global pres
pres = -1

global whole


def getone():
    global startdir
    os.chdir(startdir)
#	print(people)
    for p in people:
        os.chdir(startdir+"/"+p+".dir")
        f = open("list", "r")
        glist = f.readlines()
        glist = glist[0].strip()
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
        pres = int(random.random()*len(people))
    else:
        pres = pres+1
        if(pres >= len(people)):
            pres = 0
    infile = people[pres]
#	print("running ",infile,pres)
    # pres=len(people)
    os.chdir(startdir)
    os.chdir(infile+".dir")
    whole = infile
    f = open("list", "r")
    plist = f.readlines()
    ptr = 0
    tlist = []
    for p in plist:
        p = p.strip()
        f = open(p+".txt", "r")
#		print(p+".txt")
        try:
            tlist.append(f.read())
        except:
            print("%s %s contains bad data" % (infile, p))


class MyScene (Scene):
    def setup(self):
        global hideit
        self.background_color = 'midnightblue'
        self.background_color = 'lightgreen'
        self.background_color = 'lightblue'
        #self.background_color ='white'
        self.lastt = 0.0
        self.pick = -1
        self.hide_close(hideit)

    def hide_close(self, state=True):
        from objc_util import ObjCInstance
        v = ObjCInstance(self.view)
        for x in v.subviews():
            if str(x.description()).find('UIButton') >= 0:
                x.setHidden(state)

    def touch_began(self, touch):
        global warn
        global doblock
        global pres
        global lan2
        global whole
        global hideit
        x, y = touch.location
        sound.play_effect("Beep", 1.0)
        # sound.play_effect("Bleep",1.0)
        # sound.play_effect("Shot",1.0)
        # sound.play_effect("Woosh_2",1.0)
        if hideit and abs(x-self.size.x) < 50 and (y < 50):
            speech.say("exit")
            time.sleep(0.5)
            os.abort()
        # x,y=[10,10]
        if doblock:
            dis = 1e6
            k = -1
            ksave = -1
            for c in self.children:
                [px, py] = c.position
                dx = (px-x)**2
                dy = (py-y)**2
                k = k+1
                tdis = (dx+dy)**0.5
                if tdis < dis:
                    dis = tdis
                    ksave = k
#        			print(ksave,dis)
                    doblock = False
                    pres = ksave-1
            # print("final",dis,ksave)
            while (len(self.children) > 0):
                self.children[0].remove_from_parent()
            startit()
            return
        move_action = Action.move_to(x, y, 0.7, TIMING_SINODIAL)
        self.s2.run_action(move_action)
        speech.stop()
        pick = int(random.random()*len(warn))
        while(pick == self.pick):
            pick = int(random.random()*len(warn))
        self.pick = pick
        # speech.say(warn[pick],lan2)
        # speech.say(whole)
        # if (x < 50) and (y < 50):
        if (x < self.size.x) and (y < self.size.y):
            doblock = True
            while (len(self.children) > 0):
                self.children[0].remove_from_parent()
            # startit()

    def draw(self):
        global start_t
        global tlist, ptr, plist
        global flist
        global doblock
        global lan1
        global wait
        if speech.is_speaking():
            self.lastt = time.time()
        else:
            if doblock:
                if len(self.children) < 2:

                    k = 1
                    j = 1
                    for t in first:
                        #    					print("t=",t,self.size)
                        self.s2 = SpriteNode(t)
                        rat = self.size.y/self.s2.size.y
                        rat = rat*0.1
                        self.s2.size = self.s2.size*rat
                        self.s2.position = [self.size.x*k/9, self.size.y*j/5]
                        self.s2.position = [self.size.x *
                                            (k/9.), self.size.y*(1.1-j/5.)]
                        # self.s2.position[0]=200
                        # self.s2.position.y=self.size.y*random.random()
#    					print(self.s2.position)
                        k = k+1
                        if(k == 8):
                            k = 1
                            j = j+.75
                        self.add_child(self.s2)
                return

            if ptr >= len(plist) and not(speech.is_speaking()) and time.time() > self.lastt+5.0:
                startit()
            if ptr < len(plist) and time.time() > self.lastt+1.5:
                self.s2 = None
                p = os.getcwd()+"/"+plist[ptr].strip()+".png"
#    			print(p)
                self.s2 = SpriteNode(p)
                self.s2.position = self.size/2
                rat = self.size.y/self.s2.size.y
                self.s2.size = self.s2.size*rat
                self.add_child(self.s2)
                if ptr == 0:
                    sleep(wait)
                if (len(self.children) > 1):
                    self.children[0].remove_from_parent()
#    			print(p,tlist[ptr])
                speech.say(tlist[ptr], lan1)
                # self.touch_began(xy)
                ptr = ptr+1


startdir = os.getcwd()
# print(speech.get_languages())
lan1 = speech.get_languages()[10]
lan2 = speech.get_languages()[7]
lan1 = lan2
if False:
    k = 0
    for l in speech.get_languages():
        if str(l).find("en") > -1:
            speech.say('hello '+str(k)+str(l), l)
        k = k+1
getone()
startit()

if Alice:
    speech.say("hi - - - To start touch one of the words.", lan1)
    speech.say(
        "After the word finishes you will be presented with more words.", lan1)
    speech.say("Tap to return to the list.", lan1)
    speech.say("To exit tap the lower right corner.", lan1)
else:
    speech.say("hi - - - Welcome to mother Bruce", lan1)
run(MyScene())
