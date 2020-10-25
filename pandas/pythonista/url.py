import appex
import requests
import console
import dialogs
import os
def startdir():
	cwd=os.getcwd()
#	print("cwd=",cwd)
	basein=cwd.find("Documents")+9
	newdir=cwd[0:basein]
	os.chdir(newdir)
	cwd=os.getcwd()
	return cwd
#	print(cwd)
def setdir(top):
	cwd=os.getcwd()
	files=os.listdir(cwd)
	dirs=[]
	cwd_short=cwd.replace(top,"")
	dirs.append(".")
	dirs.append(".. "+cwd_short)
	for f in files:
			if os.path.isdir(f):
				dirs.append(f)
	#print(dirs)
	nextdir=dialogs.list_dialog("Select a directory",dirs,False,"Contiue")
	if nextdir is None:
		return(False)
	else:
		if nextdir.find("..") > -1 :
			return(True)
		if nextdir.find(".") > -1:
			up=os.getcwd()
			up=up.rstrip("/")
			upend=up.rfind("/")
			up=up[0:upend]
			os.chdir(up)
#			print("UP",up)
			return(setdir(top))
		os.chdir(cwd+"/"+nextdir)
		return(setdir(top))
def main():
	if not appex.is_running_extension():
		#print('Running in Pythonista app, using test data...\n')
		url = 'http://example.com'
		url=console.input_alert("Hello","Enter URL","http://inside.mines.edu/~tkaiser/golf.py")
	else:
		url = appex.get_url()
	if url:
		# TODO: Your own logic here...
		print('Input URL: %s' % (url,))
		r=requests.get(url)
		text=r.text
		print(text)
		top=startdir()
		if len(text) > 0:
		# TODO: Your own logic here...
#		print('Input text: %s' % text)
			diddir=setdir(top)
			newfile=""
			if diddir:
				newfile=dialogs.input_alert("File","Create file:")
				if newfile is None:
					newfile=""
				if len(newfile) > 0:
					file=open(newfile,"w")
					file.write(text)
					file.close()
	else:
		print('No input URL found.')

if __name__ == '__main__':
	main()
