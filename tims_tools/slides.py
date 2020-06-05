#!/usr/bin/env python
# coding: utf-8
global speakversion
speakversion="none"

def dohelp():
    text="""Script takes three sets of files in numerical order starting at 1.
        Images:         either 
                *[0-9[[0-9][0-9].png 
                        or 
                *[0-9[[0-9][0-9].jpeg
        Text:   0[0-9[[0-9][0-9]
        
        The text files are in two parts delimited by ====.  Everything before
        ==== will be spoken, after printend to the screen.
        
        Run the function walk to see a slide show.  For every slide for which
        there is a spoken text file it will be spoken.  The printed text will
        be shown at the end of the slide.  Use this if you want to provide some 
        text for the reader they might want to copy/paste, for example a script 
        or command.
        
        Note: Keynote allows slides to be saved as images.  The AppleScript
        uSaySlides.applescript can be used to create text files from the presenter
        notes of a Keynote presentation.   
        
        This should be run from a jupyter notebook.  For example:
           
           from slides import *
           walk()

        On Mac build in speech commands are used.  
        
        On Windows you should create a conda environment:
            conda create --name slides Jupyter Matplotlib scipy pandas 
            conda activate slides
            pip install gtts
            pip install pygame 
            
        Gtts requires an internet connection.  There may be a short delay in the
        audio.
        
    """
    print(text)
    print("using "+speakversion+" for audio")

import os
import platform
from time import time
from time import sleep
from IPython.display import Image,display
from IPython.core.interactiveshell import InteractiveShell
InteractiveShell.ast_node_interactivity = "all"
import getpass
from IPython.display import clear_output

if platform.system() == "Darwin" :
	try:
		from AppKit import NSSpeechSynthesizer
		def wsay(afile):
			#https://stackoverflow.com/questions/12758591/python-text-to-speech-in-macintosh
			#NSSpeechSynthesizer.availableVoices()
			speechSynthesizer = NSSpeechSynthesizer.alloc().init()
			speechSynthesizer.setVoice_('com.apple.speech.synthesis.voice.karen')
			x=open(afile,"r")
			txt=x.read()
			txt=txt.split("====")
			txt=txt[0]
			x.close()
			speechSynthesizer.startSpeakingString_(txt)
		speakversion="Mac NSSpeechSynthesizer"
	except:
		def wsay(afile):
			x=open(afile,"r")
			txt=x.read()
			txt=txt.split("====")
			txt=txt[0]
			x.close()
			txt=txt.replace('"',"'")
			cmd="echo \""+txt+"\" | say -v Karen --quality=128"
			x=os.popen(cmd,"r")
		speakversion="Mac say"

#if platform.system() == "Darwin" :
if platform.system() == "Windows" :
	try:
	##### conda create --name slides Jupiter Matplotlib scipy pandas 
	##### conda activate slides 
	##### pip install gtts   
	##### pip install pygame   
		from gtts import gTTS
		from io import BytesIO
		from pygame import mixer 
		def wsay(afile):
			global speakversion
			x=open(afile,"r")
			txt=x.read()
			txt=txt.split("====")
			txt=txt[0]
			x.close()
			tts = gTTS(text=txt, lang='en')
			mp3 = BytesIO()   
			tts.write_to_fp(mp3)   
			mp3.seek(0)   
			mixer.init()   
			mixer.music.load(mp3)   
			mixer.music.play() 
		speakversion="gtts (Internet Connection) "
	except:
		dohelp()

username = getpass.getuser()

#dir="/Users/tkaiser2/Desktop/sshPics"
dir=os.getcwd()

# text to be spoken
txt=[]

# images to show, either jpg or png files
lfiles=os.listdir()
img=[]
for i in lfiles :
	if i.find("jpeg") > 0:
		img.append(i)
if len(img) == 0:
	img=[]
	for i in lfiles :
		if i.find("png") > 0:
			img.append(i)
img.sort()

# optional text to show after the slide
# that can be copy/pasted
out=[]

for s in range(1,len(img)+1): 
    t=str("%4.4d" % (s))
    #t=dir+"/"+t
    txt.append(t)
    out.append("")
    #outfile=str("i%3.3d" % (s))
    try:
        #outfile=open(outfile,"r")
        outfile=open(t,"r")
        buff=outfile.read()
        buff=buff.split("====")
        if(len(buff) > 1):
        	buff=buff[1]
        else:
        	buff=""
        out[-1]=buff
        #out[-1]=outfile.read()
        out[-1]=out[-1].replace("USER",username)
    except:
        pass

def showit(txt,img,out,j,talk=True):
    i=j-1
    if talk :
        wsay(txt[i])
    display(Image(filename=img[i]))
#optional test for copy paste written after the slide
    if len(out[i]) > 0:
        #print("\033[31m")
        print(out[i])
        #print("\033[30m")
    return(j+1)

def walk(talk=True):
    j=1
    jmax=len(img)+1
    while j < jmax :
        j=showit(txt,img,out,j,talk)
        mywait=True
        back=input("Slide:"+str(j-1)+" of "+str(jmax-1)+"  Return,  R - repeat, or slide number: ")
        try :
            k=int(back)
            j=k
        except :
            pass
        if back == "R" or back == "r" :
            j=j-1
        clear_output(wait=True)
        if j < 1 : j=jmax

#help()
#walk()




