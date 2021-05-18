''' Contains class mysay for doing presentations in a Jupyter notebook
    from slideshow import mysay
    help(mysat)
'''

#!/usr/bin/env python
# coding: utf-8
import os
import platform
from time import sleep
from time import time as seconds
from IPython.display import Image,display,HTML
from IPython.core.interactiveshell import InteractiveShell
InteractiveShell.ast_node_interactivity = "all"
import getpass
from IPython.display import clear_output
global startdir
startdir=os.getcwd()

def mymovie(dir,pause=0.05,set=[0,0],extend="png"):
    ''' mymovie(dir,pause=0.05,set=[0,0],extend="png")
        poor man's movie 
         specify the directory
         pause between frames
         set of frames to see, defaults to all
         file extension
    '''
    from IPython.display import Image,display,HTML
    from IPython.display import clear_output
    from time import sleep
    from os import listdir
    files=listdir(dir)
    pngs=[]
    for f in files:
        if f.find(extend) > -1 :
            pngs.append(f)
        pngs.sort()
    if set[0] == 0 and set[1]==0:
        set[1]=len(pngs)        
    for f in pngs[set[0]:set[1]]:
        clear_output()
        display(Image(filename=dir+"/"+f))
        sleep(pause)


class mysay:
	'''Class for displaying Presentations in Jupyter notebooks
	   help() 
	   for a complete description'''

	def help(self):
		text="""Script takes two sets of files in numerical order starting at 1.
			Images:         either 
					*[0-9[[0-9][0-9].png 
							or 
					*[0-9[[0-9][0-9].jpeg
							and
			Text:   0[0-9[[0-9][0-9]
		
			The text files are in two parts delimited by a line beginning with ====.  
			Everything before ==== will be spoken, after printend to the screen.
		
			Run the function walk to see a slide show.  For every slide for which
			there is a spoken text file it will be spoken.  The printed text will
			be shown at the end of the slide.  Use this if you want to provide some 
			text for the reader they might want to copy/paste, for example a script 
			or command.
		
			Note: Keynote allows slides to be saved as images.  The AppleScript
			uSaySlides.applescript can be used to create text files from the presenter
			notes of a Keynote presentation.   
		
			This should be run from a jupyter notebook.  For example:
		   
			   from show import mysay
			   dis=mysay("linux",datadir="..")
			   dis.walk()
			   
			The datadir is the directory containing the files.  It defaults to the
			current directory.  It can be a subdirectory but you must specify a 
			relative, not absolute path.
			
			
			"linux" is this case is just an arbitrary name given to this presentation.
			It defaults to none.
			
				dis.report()
			
			will print information about the presentation including:
				name    - given name
 				counter - where you are at in the presentation
 				out     - number of text files found
 				img     - number of image files found
 				
 			Passing False to walk will surpress the speech.
 			
 			
 				dis.nx()  
 			will show the next slide.  It has several options.  The
 			defaluts are:
 				dn=1           : advance dn slides before presenting
 				talk=False     : speek      
 				wait=False     : wait for user to enter a responce before proceeding 
 				clear=False    : clear the previous image before the next
 				time=0         : sleep before proceeding
 				slide=0        : if > 0 go to that slide
 				
 			Useful combinations:
 				dis.nx(talk=True,wait=True)
 	 			dis.nx(talk=False,wait=True)
 	 			# put 5 images in a window quickly
 	 			for i in range(0,5):
 	 			    dis.nx(talk=False,wait=False,clear=False)
  	 			# put 5 images in a window waiting for user input
 	 			for i in range(0,5):
 	 			    dis.nx(talk=True,wait=True,clear=False)
  	 			# put 5 images in a window waiting 5 seconds between images
 	 			for i in range(0,5):
 	 			    dis.nx(talk=True,clear=False,time=5)
  	 			# put 5 images in a window waiting 5 seconds between images
  	 			# but clearing the previous image
 	 			for i in range(0,5):
 	 			    dis.nx(talk=True,clear=True,time=5)
            
            
            ####################################################
            
			On Mac build in speech commands are used.  
		
			On Windows you should create a conda environment:
				conda create --name slides Jupyter Matplotlib scipy pandas 
				conda activate slides
				pip install gtts
 
			
			The gtts  also works on a Raspberry Pi and on the Mac.
			
			Gtts requires an internet connection.  There may be a short delay in the
			audio.
			
		DEMO with mpi4py and some canned presentations
			from slideshow import mysay
			pwd
			ls
			slides=mysay(datadir="slides")
			pwd
			slides.walk()
			pwd
			cd ..
			ssh=mysay(datadir="sshtalk",system="local")
			ssh.report()
			ssh.walk()
			slides.report()
			slides.nx(talk=True)
			cd ~/examples/mpi/mpi4py
			ls
			%load_ext slurm_magic
			srun -n 4 ./P_ex02.py
			slides.nx(talk=True)
		"""
		print(text)
		print("using "+self.speakversion+" for audio")

	def __init__(self,name="none",datadir="..",system="none"):
		if name == "none" :
			name=str(int(seconds()))
		self.name = name
		
		global startdir
		self.startdir=startdir
		self.counter=1
		os.chdir(datadir)
		self.datadir=datadir
		self.saveddir=self.startdir
		self.talkfailed=False
		self.speakversion="none"
		if system == "none" :
			self.system=platform.system()
		else:
			self.system=system
		if self.system == "Darwin" :
			try:
				from AppKit import NSSpeechSynthesizer
				#from AppKit import NSSpeechSynthesizer
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
				self.speakversion="Mac NSSpeechSynthesizer"
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
				self.speakversion="Mac say"
#local
		if self.system == "local"  :
#			print("local")
			def wsay(afile):
				if self.talkfailed : return()
				from os.path import isfile
				afile=afile+".wave"
				if isfile(afile) :
					pass
				else :
					return
				ofile="""<!DOCTYPE html>
<html>
<head>
<title></title>
</head>
<body>
<audio controls autoplay>
<source src="../OUT" type="audio/wave">
Your browser does not support the audio element.
</audio>
</body>
</html>
"""
				ofile=ofile.replace("OUT",afile)
				ofile=ofile.replace("..",self.datadir)
				#print(ofile)
				try:
					display(HTML(ofile))
				except:
					print("talk failed")
					self.talkfailed=True
			self.speakversion="local "


		if self.system == "Windows" or self.system == "Linux" :
			try:
			##### conda create --name slides Jupiter Matplotlib scipy pandas 
			##### conda activate slides 
			##### pip install gtts   
				from gtts import gTTS
				def wsay(afile):
					global speakversion
					if self.talkfailed : return()
					x=open(afile,"r")
					txt=x.read()
					txt=txt.split("====")
					txt=txt[0]
					x.close()
					if len(txt) > 0:
						tts = gTTS(text=txt, lang='en')
						tts.save(self.name+".mp3")
					ofile="""<!DOCTYPE html>
<html>
<head>
	<title></title>
</head>
<body>
<audio controls autoplay>
  <source src="../OUT.mp3" type="audio/mp3">
  Your browser does not support the audio element.
</audio>
</body>
</html>
"""
					ofile=ofile.replace("OUT",self.name)
					ofile=ofile.replace("..",self.datadir)
					try:
						if len(txt) > 0:
							#print(ofile)
							display(HTML(ofile))
						#os.remove(self.name+".mp3")
					except:
						print("talk failed")
						self.talkfailed=True
				self.speakversion="gtts (Internet Connection) "
			except:
				def wsay(afile):
					global speakversion
					x=open(afile,"r")
					txt=x.read()
					txt=txt.split("====")
					txt=txt[0]
					x.close()
					#tts = gTTS(text=txt, lang='en')
					print("no speech module found")

		username = getpass.getuser()
		self.wsay=wsay

		if (self.datadir == "..") :
			dir=os.getcwd()
		else:
			dir=datadir
		self.datadir=dir
		#os.chdir(dir)

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
		self.out=out
		self.txt=txt
		self.img=img
	def popd(self):
		#print("poping to: ",self.saveddir,"from",os.getcwd())
		os.chdir(self.saveddir)
		
	def pushd(self):
		self.saveddir=os.getcwd()
		#print("pushing: ",self.saveddir,"going to",self.startdir)
		os.chdir(self.startdir)
		os.chdir(self.datadir)

	def showit(self,txt,img,out,j,talk=True):
		self.pushd()
		i=j-1
		#if talk :
		#	self.wsay(txt[i])
		#sleep(10)
		
		display(Image(filename=img[i]))
		if talk : self.wsay(txt[i])
	#optional test for copy paste written after the slide
		if len(out[i]) > 0:
			#print("\033[31m")
			print(out[i])
			#print("\033[30m")
		self.popd()
		return(j+1)

	def walk(self,talk=True):
		'''Show a presentation.
		
		walk(talk=True)
		
	   help() for a complete description'''


		out=self.out
		txt=self.txt
		img=self.img
		j=1
		jmax=len(img)+1
		out=self.out
		
		while j < jmax :
			j=self.showit(txt,img,out,j,talk)
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
	def report(self):
		'''Show a information about a presentation.
		
		 report()
		 
	   help() for a complete description'''

		print("            name: ",self.name)
		print("         counter: ",self.counter)
		print("       directory: ",self.datadir)
		print("     talk failed: ",self.talkfailed)
		print("speech synthesis: ",self.speakversion)
		print("# data:" )
		print("out:" ,len(self.out))
		print("txt:" ,len(self.txt))
		print("img:" ,len(self.img))

	def nx(self,dn=1,talk=False,wait=False,clear=False,time=0,slide=0):
		'''Show a slide from a presentation.
		
		 nx(dn=1,talk=False,wait=False,clear=False,time=0)
	   
	   help() for a complete description'''

		txt=self.txt
		out=self.out
		img=self.img
		jmax=len(self.img)
		dn=dn-1
		# counter actually points to the next scheduled slide
		j=self.counter+dn
		if(j < 1): j=1
		if(j > jmax) :
			print("at the end")
			return (0)
		if(slide > 0) : j=slide
		j=self.showit(txt,img,out,j,talk)
		if wait :
			jmax=len(self.img)
			back=input("Slide:"+str(j-1)+" of "+str(jmax-1)+"  Return,  R - repeat, or slide number: ")
			try :
				k=int(back)
				j=k
			except :
				pass
			if back == "R" or back == "r" :
				j=j-1
			clear_output(wait=True)
		if clear : clear_output(wait=True)
		self.counter=j
		sleep(time)
		return(j)

			

		
		
#help()
#walk()




