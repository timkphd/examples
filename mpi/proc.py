#!/usr/bin/env python
#080713200729;
#0123456789012
def getrecs(lines)
	recs=[]
	lc=0
	for line in lines:
		lc=lc+1
		ok=False
		if (line[12] == ";"):
			ok=True
			try:
				x=int(line[0:12])
			except:
				ok=False
		if(ok):
			rec.append(lc)
	return recs


file="~/Desktop/Set 1.csv"
f=open(file,"r")
mylines=f.readlines()
f.close()
starts=getrecs(mylines)


	