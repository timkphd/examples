import os
for case in ["intel","gcc"] :
    command='egrep " #|^d"  mixedModeBenchmark.XXX.out > out.txt'
    command=command.replace("XXX",case)
    f=os.popen(command,"r")
    bonk=f.readlines()
    inf=open("out.txt","r")
    file="none"
    lines=inf.readlines()
    for lin in lines:
        if lin.find("#") > -1:
            inf.close()
            name=lin.strip()
            name=name.replace("#","")
            name=name.lstrip()
            name=name.replace(" ","_")
            print(name)
            inf=open(name+"."+case,"w")
        else :
            if lin.find("d") == 0:
                #print(lin)
                lin=lin.split()
                size=lin[1]
                t=lin[5]
                print(size,t)
                inf.write(size+" "+t+"\n")
    
