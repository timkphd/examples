#!/usr/bin/env python3

"""
(3.11.7b) [tkaiser2@kl1 junk]$vi setup.py

from distutils.core import setup, Extension

setup (name = 'tymer',
       version = '1.0',
       description = 'This is a utililty module with a tymer',
       py_modules = ['tymer'])


##python setup.py install
"""


#### copy this file to ~/bin
#### ln -s tymer myutils.py
import sys
import time
import os.path
global doquit
doquit=False

import io 
def sprint(*args, **kwargs): 
	'''Use like print but returns a string instead of printing.'''
	sio = io.StringIO() 
	print(*args, **kwargs, file=sio) 
	return sio.getvalue() 
	 
def pdappend(df,line):
    import pandas as pd
    a_series = pd.Series(line, index = df.columns)   
    return df.append(a_series, ignore_index=True)   

def pdaddrow(indf,inline,dell=" "):
    import pandas as pd
    if type(inline) == str:
        inline=inline.split(dell)
    cols=indf.columns
    if len(cols) != len(inline):
        print("in pdaddrow row length mismatch dataframe = ",len(cols), " input row = ",len(inline))
        print(inline)
        if dell == "\t":
            print("delimiter is tab")
        else:
            print("delimiter is ",dell)
        return indf
    adict={}
    for (h,v) in zip(cols,inline) :
        adict[h]=[v]
    #print(adict)
    inline=pd.DataFrame(adict)
    return(pd.concat([indf,inline],ignore_index = True))
 
 
def rreplace(s, old, new="",count=1):
    return (s[::-1].replace(old[::-1], new [::-1], count))[::-1]


#returns output from the magic command %%capture as a list
def clist(cap):
	'''Returns output from the magic command %%capture as a list'''
	if len(cap._stdout.__getstate__()[0]) > 0:
		return(cap.stdout.split())
	rstr=""
	for i in cap._outputs :
		try:
			s=i['data']['text/plain']
			s=s.replace("\\n","\n")
			s=s.strip("'")
			rstr=rstr+sprint(s)
		except:
			pass
	return(rstr.split())


def greenbar(input,color="green"):
    if input == "help":
        print("Adds a css to a html file, in particular a table")
        print("NORMAL USAGE:")
        print("Assuming we have a dataframe 'bytime'")
        print('tmp=bytime.to_html(index=False)')
        print('tmp=greenbar(tmp,color="blue")')
        print('f=open("top_users.html","w")')
        print('f.write(tmp)')
        print('f.close()')
        return None
    header="""<!DOCTYPE html>
<html lang="en">
<head>    
 <meta charset="utf-8" />
 <title>Untitled</title>
<style>
BODY { background-color: #DDD; }
.greenbar { font-family: "Trebuchet MS", Arial, Helvetica, sans-serif; border-collapse: collapse; width: 100%; }
.greenbar th { font-size: 1.4em; text-align: center; padding-top: 5px; padding-bottom: 4px; background-color: #A7C942; color: #fff; }
.greenbar td { font-size: 1.0em; border: 1px solid #98bf21; text-align: right; padding: 3px 7px 2px 2px; }
.greenbar tr:nth-child(odd) td { color: #000; background-color: #EAF2D3; }
.greenbar tr:nth-child(even) td { color: #000; background-color: #ffffff; }
.greenbar td:nth-child(300n+0) { text-align: left; }
.greenbar td:nth-child(400n+0) { text-align: center; }
.greenbar td:nth-child(500n+0) { text-align: right; }
.bluebar { font-family: "Trebuchet MS", Arial, Helvetica, sans-serif; border-collapse: collapse; width: 100%; }
.bluebar th { font-size: 1.4em; text-align: left; padding-top: 5px; padding-bottom: 4px; background-color: #646490; color: #fff; }
.bluebar td { font-size: 1.0em; border: 1px solid #0000ff; padding: 3px 7px 2px 2px; }
.bluebar tr:nth-child(odd) td { color: #000; background-color: #DCDCFF; }
.bluebar tr:nth-child(even) td { color: #000; background-color: #ffffff; }
.bluebar td:nth-child(300n+0) { text-align: left; }
.bluebar td:nth-child(400n+0) { text-align: center; }
.bluebar td:nth-child(500n+0) { text-align: right; }
.narrow { width: 25%; text-align: center; }
</style>
<table class="bluebar">  
"""
    if color== "green" :
        header=header.replace('class="bluebar"','class="greenbar"')
    tail="""</body>
</html>
"""
    tmp=input.replace('<table border="1" class="dataframe">',"")

    return header+tmp+tail


