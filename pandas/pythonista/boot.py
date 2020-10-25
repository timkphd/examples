import requests
from shutil import copyfileobj
for p in ["getit.py","sprite.py"] :
  r=requests.get("http://petra.mines.edu/projects/pngs/"+p,stream=True)
  with open(p,"wb") as out_file:
    copyfileobj(r.raw,out_file)
