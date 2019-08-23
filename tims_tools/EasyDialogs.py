from sys import *
def AskFileForOpen(message="file="):
	fstring=input(message)
	return fstring
def AskString(message="input:",default=""):
	prompt=message+": "+default+" "
	fstring=input(prompt)
	if(len(fstring)==0):
		fstring=default
	return fstring
