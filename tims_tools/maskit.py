#!/usr/bin/env python
# coding: utf-8

# In[ ]:


# various utilites for work with masks and permissions
import os
import subprocess
import grp
from shutil import rmtree as del_dir

# set the group for a file
def setgroup(file,newgrp):
    newgrp = grp.getgrnam(newgrp).gr_gid
    os.chown(file,-1,newgrp)
    

# get the current mask setting, output is an integer, base 10
def getmask():
    current=os.umask(0)
    junk=os.umask(current)
    return current

# set the mask, input is an integer, base 10
def setmask(amask):
    current=os.umask(amask)
    return amask

# utility routine to return a text permission str from octal
# of the from '0o734' -> 'rwx-wxr--'
def octtostr(octin):
    octin=octin.split("o")[1]
    if len(octin)== 1:
        octin="00"+octin
    if len(octin)== 2:
        octin="0"+octin
    mystr=""
    pos=["---",'--x','-w-','-wx','r--','r-x','rw-','rwx']
    for x in octin:
        x=int(x)
        mystr=mystr+pos[x]
    return(mystr)

# utility routine to return a octal permission str from text
# of the from 'rwx-wxr--' -> '0o734'
def strtooct(x):
    if(len(x) == 10):
        x=x[1:]
    if(len(x) != 9):
        print("filetomask requires a str of length 9 or 10, for example: 'rwxr-xr-x','drwxrwx---',-rwxr-xr-x")
        return('0o000')
    u=x[0:3]
    g=x[3:6]
    w=x[6:]
    #print(u,g,w)
    pos=["---",'--x','-w-','-wx','r--','r-x','rw-','rwx']
    u=pos.index(u)
    g=pos.index(g)
    w=pos.index(w)
    octval=("0o%1d%1d%1d" % (u,g,w))
    return(octval)
    #decval=int(octval,8)




# input a mask and return what the permissions should be
# Note: umask is subtractive, not prescriptive: permission 
# bits set in umask are removed by default from modes 
# specified by programs, but umask can't add permission bits.
def masktofile(x):
    if x.find('o') > -1 :
        x=int(x,8)
    else:
        x=int(x)
    return(octtostr(oct(x ^ 0o777)))

# input the permissions you want and return what mask you need
# Note: umask is subtractive, not prescriptive: permission 
# bits set in umask are removed by default from modes 
# specified by programs, but umask can't add permission bits.
def filetomask(x):
    if(len(x) == 10):
        x=x[1:]
    if(len(x) != 9):
        print("filetomask requires a str of length 9 or 10, for example: 'rwxr-xr-x','drwxrwx---',-rwxr-xr-x")
        return('0o000')
    u=x[0:3]
    g=x[3:6]
    w=x[6:]
    #print(u,g,w)
    pos=["---",'--x','-w-','-wx','r--','r-x','rw-','rwx']
    u=pos.index(u)
    g=pos.index(g)
    w=pos.index(w)
    octval=("0o%1d%1d%1d" % (u,g,w))
    decval=int(octval,8)
    #return(decval)
    s=oct(decval ^ 0o777)
    if len(s) == 3:
        s=s.replace("o","o00")
        return(s)
    if len(s) == 4:
        s=s.replace("o","o0")
    return(s)

# do a setgid bit on a directory so that that all files 
# and directories newly created within it inherit the 
# group from that directory.
##### chmod g+s adir #####
# setgid is represented with a lower-case "s" in the 
# output of ls. In cases where it has no effect it 
# is represented with an upper-case "S".
def dsetgid(adir):
    statinfo = os.stat(adir)
    n=statinfo.st_mode+int('2000',8)
    os.chmod(adir,n)
    
#see https://www.linuxquestions.org/questions/linux-desktop-74/applying-default-permissions-for-newly-created-files-within-a-specific-folder-605129/
def setfacl(file, perms="rx",who="g"):
    cmd="setfacl -d -m"+who+"::"+perms+" "+file
    #print(cmd)
    try:
        #python 3
        doit=subprocess.run(cmd,capture_output=True,shell=True,encoding='utf-8') 
        stdout=doit.stdout
        stderr=doit.stderr
    except:
        #python 2
        input, out, err = os.popen3(cmd)
        stdout=out.read()
        stderr=err.read()
    #print(doit)
    if stderr.find("command not found") > -1:
        # mac os handels acls differently, actually more versatile 
        print("setfacl not supported on this platform. Try chmod +a")
        print("see https://gist.github.com/nelstrom/4988643#file-access-control-lists-on-osx-md")
    if len(stdout) > 0:
       print(stdout)

#see https://www.linuxquestions.org/questions/linux-desktop-74/applying-default-permissions-for-newly-created-files-within-a-specific-folder-605129/
def getfacl(file, opts="-e"): 
    cmd="getfacl "+opts+" "+file
    doit=os.popen(cmd,"r")
    out=doit.read()
    if out.find("command not found") > -1:
        print("getfacl not supported on this platform. Try chmod")
        print("see https://gist.github.com/nelstrom/4988643#file-access-control-lists-on-osx-md")
    if len(out) > 0:
       print(out)


#lists the directories created testit
def dodir():
    dolist=os.popen("ls -lt f*","r")
    flist=dolist.read()
    print(flist)

    dolist=os.popen("ls -lt | grep ^d","r")
    flist=dolist.read()
    print(flist)


# In[ ]:


doit=False


# In[ ]:


#testit sets up files and directories with various permissions
#'rwxrwxrwx','rwxrw----','rwxrwx---','rwxr-x---','rwxrwx---','rwx------','rwxr-xr-x'
def testit():
    sets=['rwxrwxrwx','rwxrw----','rwxrwx---','rwxr-x---','rwx------','rwxr-xr-x']
    force_dir=False
    force_file=False
    for s in sets:
        newmask=filetomask(s)
        peroct=strtooct(s)
        f="f"+peroct
        d="d"+peroct
        print(newmask,peroct)
        #mkdir ignores the setting of umask
        try:
            del_dir(d)
        except:
            pass
        setmask(int(newmask,8))
        if force_dir: os.mkdir(d,mode=int(peroct,8))
        os.mkdir(d)
        try:
            os.remove(f)
        except:
            pass
        afile=open(f,"w")
        # A file will not have x permission even if allowed by the
        # mask unless it is set by chmod or created as an executable.
        if force_file : os.chmod(f,int(int(peroct,8)))
        afile.close()
    dodir()

    print("""          Things to try :\n
from maskit import *
dodir()
dsetgid('d0o755')
dsetgid('d0o750')
setgroup('d0o750','naermpcm')
setgroup('d0o755','naermpcm')
dodir()
setfacl('d0o750')
dodir()\n""")
    print("""Now create files including executables in the directories and see the diffferences.
For example, external to python:\n
echo 'main () {int printf(const char *f, ...) ; printf("hi\\n");}' > hi.c
cd d0o750
touch afile
gcc ../hi.c 
cd ..
cd d0o755
touch afile
gcc ../hi.c 
cd ..
cd d0o770
touch afile
gcc ../hi.c 
cd ..
ls -ld d*
ls -ld d0o750 d0o755 d0o770
ls -lR d0o750 d0o755 d0o770
""")
          
shell="""
masks=(000 017 007 027 077 022)
names=(0o777 0o760 0o770 0o750 0o700 0o755)
rm -rf d* f*
for i in ${!masks[@]}; do umask ${masks[i]}; mkdir d${names[i]}; touch f${names[i]}; done
chmod g+s d0o755
chmod g+s d0o750
chown :naermpcm d0o750
chown :naermpcm d0o755
setfacl -d -mg::rx d0o750

echo 'main () {int printf(const char *f, ...) ; printf("hi\\n");}' > hi.c
cd d0o750
touch afile
gcc ../hi.c 
cd ..
cd d0o755
touch afile
gcc ../hi.c 
cd ..
cd d0o770
touch afile
gcc ../hi.c 
cd ..
ls -ld d*
ls -ld d0o750 d0o755 d0o770
ls -lR d0o750 d0o755 d0o770

"""




# In[ ]:


if __name__ == '__main__' or doit == True:
    testit()


