#!/usr/bin/env python
"""\
noName.py
	Goes through a command file and executes the commands on every
	file in the directory.
	Command Line Arguments (default value enclosed in brackets):
	format=<FORMAT>: ['.+']
		Specifies a name filter to be performed on the files in the
		working directory.  The filter must be of a valid perl
		regular expression format.  

		The expression must be enclosed in either ' ' or " " in
		order to be passed into the program.  This is because many
		of the regular expression formats are expanded inline if not
		enclosed.

		The following is no longer true.  Nothing is inserted.
		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		The filter automatically inserts ^ at the front and $ at the
		end of your expression.  This makes it so '.' will only match
		files of length 1 rather than any file that has at least 1
		character in it.  
		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	file=<FILENAME>: [commands]
		Specifies the file that the set of commands exist in.  The file
		is assumed to be relative to the directory that the program
		starts in unless an absolute path is specified.
	procPerNode=<NUMBER>: [1]
		Specifies the number of processors on any given node.  This 
		value is tied into the 'percent' field if specified.
	percent=<P/P/P/.../P>: [100.0/ppn]*(ppn-1)
		specifies the processor distribution for a given processing
		node.  There should be n-1 total values in the percent field
		where n is the number of processors per node.  The percents
		are all seperated by '/'s.  The last node is assumed to take
		all remaining files in the list.  Percents that sum to over
		100% are accepted.  All nodes past where the percent gets to
		100 will not process any files.  For example, if only nodes
		2 and 4 were supposed to do any processing on a 8 node system,
		an acceptable distribution would be: 0/0/50/0/50/0/0 or even
		0/0/50/0/1000/2000/3000.
		If an invalid number of processor percents is inputed, the
		program will default to an evenly divided processor
		distribution.
		These percents will be ignored if a subdirectory of the form
		#### (4 digit left 0 padded processor ID) is found in the 
		working directory.  In this case, the program will have the
		process work on all the chosen files in this directory.
	wdir=<DIRECTORY>: [cwd]
		Specifies the working directory for the process.  The default
		is the directory that the process is run from.
	dummy=<NAME>: [DUMMY]
		Specifies the text to be replaced by the file name.
	skip=<NUMBER>: [1]
		Use every skip processors.  That is, if skip is 1 then every
		processor will be used in the calculation.  If skip is 2 then
		processors 0,2,4... wil be used.  
	strip=<NUMBER>: [0]
		strips up to NUMBER suffixes off the file name (the program
		will strip as many as it can) If you only want to strip one
		level you could alternatively just pass in 'strip' as a 
		command line argument.
	verbose: [OFF]
		Processes will output whether each command succeeded or failed
		as the process finishes.
		
- Development Team:
	GEON Project: San Diego Supercomputer Center
- Authors:
	Tim Kaiser
	Tim Bollman
- $Revision: 1.1.1.1 $
- $Date: 2006/04/28 21:40:28 $
"""
import sys
import os
from os import access, F_OK
import re
import Numeric
from Numeric import *
import mpi
from mpi import *
import subProcess


def packString(string):
	"Packs string into an array of characters(ints)"
	n=len(string)
	chrArray=zeros(n,"i")
	for j in range (0, n):
		chrArray[j] = ord(string[j:j+1])
	return chrArray

def unpackString(chrArray):
	"unpacks an array of characters(ints) into a string"
	i=len(chrArray)
	string=""
	for j in range(0, i):
		string += chr(chrArray[j])
	return string

def commandNode():
	global numProcs, myId, fileName, format, procPerNode, percent, lines, output, numStrips, baseDir, dummyString, TIM_COMM_WORLD
	fileName = "%s/commands" % baseDir
	key = value = ""
	# see if the user sent in any specific arguments
	for arg in sys.argv:
		firstEqual = arg.find("=")
		(key,value) = (arg[:firstEqual], arg[firstEqual+1:])
		if firstEqual != -1:
			if key == "format":
#				format = "^" + value.strip('\'"') +"$"
				format = value.strip('\'"')
			elif key == "file":
				if value[0] != '/':
					fileName = "%s/%s" % (startDir, value)
				else:
					fileName = value
			elif key == "procPerNode":
				procPerNode = int(value)
				# yes, that comma is supposed to be there, it makes the value a tuple
				percent = (100.0/procPerNode,)*(procPerNode-1)
			elif key == "percent":
				percent = value.split('/')
				for i in range(0,len(percent)):
					percent[i] = float(percent[i])
				percent = tuple(percent)
			elif key == "wdir":
				baseDir = value
			elif key == 'dummy':
				dummyString = value
			elif key == 'strip':
				numStrips = max(int(value),0)
		else:
			if arg == 'verbose':
				output = True
			elif arg == 'strip':
				numStrips = 1
			else:
				sys.stderr.write("Unknown command: %s\n" % arg)
	del key, value

	if len(percent) != (procPerNode-1):
		sys.stderr.write("Invalid length of percent string (%d), should be %d\n" % (len(percent), procPerNode-1))
		sys.stderr.write("Using default value (%.2f) for percents\n" % (100.0/procPerNode))
		percent = (100.0/procPerNode,)*(procPerNode-1)	
	# broadcast the command line arguments to other nodes
	# only send the strings if they are different from the defaults
	if format != ".":
		buffer = packString(format)
		length = len(buffer)
		mpi_bcast(length,1,MPI_INT,0,TIM_COMM_WORLD)
		mpi_bcast(buffer,length,MPI_INT,0,TIM_COMM_WORLD)
	else:
		mpi_bcast(-1,1,MPI_INT,0,TIM_COMM_WORLD)
	if baseDir != startDir:
		buffer = packString(baseDir)
		length = len(buffer)
		mpi_bcast(length,1,MPI_INT,0,TIM_COMM_WORLD)
		mpi_bcast(buffer,length,MPI_INT,0,TIM_COMM_WORLD)
		if baseDir[0] != '/':
			baseDir = "%s/%s" % (startDir, baseDir)
	else:
		mpi_bcast(-1,1,MPI_INT,0,TIM_COMM_WORLD)
	if dummyString != 'DUMMY':
		buffer = packString(dummyString)
		length = len(buffer)
		mpi_bcast(length,1,MPI_INT,0,TIM_COMM_WORLD)
		mpi_bcast(buffer,length,MPI_INT,0,TIM_COMM_WORLD)
	else:
		mpi_bcast(-1,1,MPI_INT,0,TIM_COMM_WORLD)
	mpi_bcast(procPerNode,1,MPI_INT,0,TIM_COMM_WORLD)
	if procPerNode > 1:
		buffer = array(percent,'d')
		mpi_bcast(buffer,procPerNode-1,MPI_DOUBLE,0,TIM_COMM_WORLD)
	mpi_bcast(output,1,MPI_INT,0,TIM_COMM_WORLD)
	mpi_bcast(numStrips,1,MPI_INT,0,TIM_COMM_WORLD)
	if not access(fileName, F_OK):
		# We need to quit because we don't have commands!  Don't know
		# how.  Should I just call mpi_finalize()?
		sys.stderr.write("file %s doesn't exist\n" % fileName)
		numLines=0
	else:
		file = open(fileName, "r")
		# get all the lines in the file
		lines = file.readlines()
		file.close()
		numLines = len(lines)
	# send the number of lines in the command file to the other nodes
	mpi_bcast(numLines,1,MPI_INT,0,TIM_COMM_WORLD)
	if numLines == 0 :
		mpi_barrier(MPI_COMM_WORLD)
		mpi_finalize()
		sys.exit(0)
		
	# go through the lines of the command file, pack them into an integer array,
	# and then send that off to all the nodes (after sending the size of course)
	for i in range(0,numLines):
		lines[i] = lines[i].strip()
		buffer = packString(lines[i])
		length = len(buffer)
		mpi_bcast(length,1,MPI_INT,0,TIM_COMM_WORLD)
		mpi_bcast(buffer,length,MPI_INT,0,TIM_COMM_WORLD)

def droneNode():
	global numProcs, myId, format, procPerNode, percent, lines, output, numStrips, dummyString, baseDir, TIM_COMM_WORLD
	# find out special formatting needs
	# default inits
	buffer = numLines = icount = 0
	lines = []
	# get the command line arguments from the root node
	icount = int(mpi_bcast(icount,1,MPI_INT,0,TIM_COMM_WORLD))
	# if icount == -1, format was default
	if icount != -1:
		buffer = mpi_bcast(buffer,icount,MPI_INT,0,TIM_COMM_WORLD)
		format = unpackString(buffer)
	icount = int(mpi_bcast(icount,1,MPI_INT,0,TIM_COMM_WORLD))
	# if icount == -1, baseDir was default
	if icount != -1:
		buffer = mpi_bcast(buffer,icount,MPI_INT,0,TIM_COMM_WORLD)
		baseDir = unpackString(buffer)
		if baseDir[0] != '/':
			baseDir = "%s/%s" % (startDir, baseDir)
	icount = int(mpi_bcast(icount,1,MPI_INT,0,TIM_COMM_WORLD))
	# if icount == -1, dummyString was default
	if icount != -1:
		buffer = mpi_bcast(buffer,icount,MPI_INT,0,TIM_COMM_WORLD)
		dummyString = unpackString(buffer)
	procPerNode = int(mpi_bcast(procPerNode,1,MPI_INT,0,TIM_COMM_WORLD))
	if procPerNode > 1:
		buffer = mpi_bcast(buffer,procPerNode-1,MPI_DOUBLE,0,TIM_COMM_WORLD)
		percent = tuple(buffer)
	output = int(mpi_bcast(output,1,MPI_INT,0,TIM_COMM_WORLD))
	numStrips = int(mpi_bcast(numStrips,1,MPI_INT, 0,TIM_COMM_WORLD))
	# get the number of lines from the root.	
	numLines = int(mpi_bcast(numLines,1,MPI_INT,0,TIM_COMM_WORLD))
	if numLines == 0:
		mpi_barrier(MPI_COMM_WORLD)
		mpi_finalize()
		sys.exit(0)
	# get all the lines we want from the root and unpack them
	# back into strings.
	for i in range(0, numLines):
		icount = mpi_bcast(icount,1,MPI_INT,0,TIM_COMM_WORLD)
		buffer = mpi_bcast(buffer,icount,MPI_INT,0,TIM_COMM_WORLD)
		line = unpackString(buffer)
		lines.append(line)
	del line

sys.argv = mpi_init(len(sys.argv),sys.argv)[1:]
myId = mpi_comm_rank(MPI_COMM_WORLD)
numProcs = mpi_comm_size(MPI_COMM_WORLD)
skip=1
if myId == 0:
	for arg in sys.argv:
		firstEqual = arg.find("=")
		(key,value) = (arg[:firstEqual], arg[firstEqual+1:])
		if key == "skip":
			skip=int(value)
skip = mpi_bcast(skip,1,MPI_INT,0,MPI_COMM_WORLD)
if skip < 1 :
	skip=1
num_used=numProcs/skip
will_use=zeros(num_used,"i")
old_group=mpi_comm_group(MPI_COMM_WORLD)
# create a new group from the old group 
# that will contain a subset of the  processors
istart=0
for ijk in range(0, num_used):
		will_use[ijk]=ijk
		print will_use[ijk]
		istart=istart+skip
new_group=mpi_group_incl(old_group,num_used,will_use)
# create the new communicator
TIM_COMM_WORLD=mpi_comm_create(MPI_COMM_WORLD,new_group)
# test to see if i am part of new_group.
user_id=mpi_group_rank(new_group)
if user_id == MPI_UNDEFINED:
# if not part of the new group do keyboard i/o.
		mpi_barrier(MPI_COMM_WORLD)
		mpi_finalize()
		sys.exit(0)

myId = mpi_comm_rank(TIM_COMM_WORLD)
numProcs = mpi_comm_size(TIM_COMM_WORLD)

startDir = os.getcwd()

baseDir = os.getcwd()
format = "."
percent = []
output = False
numStrips = 0
doFileSplit = True
procPerNode = 1
dummyString = 'DUMMY'

if myId == 0:
	commandNode()
else:
	droneNode()


# stuff to change directory to working directory
idDir = "%04d" % myId
if (access(baseDir, F_OK)):
	if access("%s/%s" % (baseDir, idDir), F_OK):
		os.chdir("%s/%s" % (baseDir, idDir))
		doFileSplit = False
	else:
		os.chdir(baseDir)
else:
	# I don't take any actions at the moment
	sys.stderr.write("[%d]directory %s does not exist.\n" % (myId, baseDir))

#Filter to take out files that don't match our parameters
def myFilter(x): return bool(re.search(format,x))
# get the list of files
files = os.listdir('.')
# apply our filter
files = filter(myFilter,files)
# if even processor get lower portion of listing
if doFileSplit and procPerNode > 1:
	loc = myId % procPerNode
	start = 0.0
	i = 0
	while i < loc:
		start += percent[i]
		i += 1
	if loc != procPerNode-1:
		end = int((start + percent[i])*len(files)/100.0)
	else:
		end = len(files)
	start = int(start*len(files)/100.0)
	files = files[start:end]
	
# I put a barrier here in case one or more of the commands is to remove
# or create a file in the directory, making it so that the file lists
# are not the same.
mpi_barrier(TIM_COMM_WORLD)
# go through and run each command on each file.  We do this
# by going through the line and replacing DUMMY with the file name, then
# executing the command.  We also capture the stderr and stdout of the
# process and report it to the user. (Eventually this will be in a file)
errors = 0
outfile = open("%s/results%04d" % (startDir, myId), "w")
for file in files:
	outfile.write("*commands for file '%s'\n" % file)
	if output:
		print "[%d] commands for file '%s'" % (myId, file)
	for i in range(0, numStrips):
		loc = file.rfind('.')
		if loc != -1:
			file = file[:loc]
		else:
			break
	for line in lines:
		# only overwrites our temporary copy, not the line in the list
		line = line.replace(dummyString,file)
		process = subProcess.subProcess(line)
		process.read()
		procError = len(process.errdata)
		string = "CMD:\n%s" % line
		string += "\nOUT:\n%s" % process.outdata
		if procError > 0:
			if output:
				print "[%d] %s: FAILURE" % (myId, line)
			string += "\nERR:\n%s" % process.errdata
			errors += 1
		else:
			if output:
				print "[%d] %s: SUCCESS" % (myId, line)
		outfile.write(string)
		process.cleanup()
outfile.close()
retRay = mpi_gather(errors,1,MPI_INT,1,MPI_INT,0,TIM_COMM_WORLD)
if myId == 0:
	for i in range(0,numProcs):
		if retRay[i] != 0:
			print "[%d] reports %d errors." % (i, retRay[i])
		else:
			print "[%d] reports all commands executed successfully" % i
mpi_barrier(MPI_COMM_WORLD)
mpi_finalize()
