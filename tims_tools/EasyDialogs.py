from sys import *
def AskFileForOpen(message="file="):
	fstring=raw_input(message)
	return fstring
def AskString(message="input:",default=""):
	prompt=message+": "+default+" "
	fstring=raw_input(prompt)
	if(len(fstring)==0):
		fstring=default
	return fstring
