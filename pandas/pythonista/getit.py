import requests
import os
from shutil import copyfileobj
startdir=os.getcwd()
dir="http://petra.mines.edu/projects/pngs/"
url=dir+"list"
r=requests.get(url,stream=True)
x=r.content
x=x.decode()
f=open("people","w")
f.write(x)
f.close()
people=x.split("\n")
for p in people:
	if len(p) < 2:
		continue
	dir="http://petra.mines.edu/projects/pngs/"+p
	base=""
	os.chdir(startdir)
	try:
		os.mkdir(p+".dir")
	except:
		pass
	os.chdir(p+".dir")
	for end in [".png",".txt"]:
		count=0
		for c in range(1,100):
			url=dir+"/"+base+("%4.4d" % (c))+end
			print(url)
			r=requests.get(url,stream=True)
			print(r.status_code)
			if r.status_code != 200:
				break
			count=count+1
			outfile=base+("%4.4d" % (c))+end
			with open(outfile,"wb") as out_file:
				copyfileobj(r.raw,out_file)
			del r
	f=open("list","w")
	for c in range(1,count+1):
			f.write(base+("%4.4d" % (c))+"\n")
	f.close()
	
	
