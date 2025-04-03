def fun0(x):
    return(x)

def fun1(x):
    return(x+1)

def fun2(x):
    return(x+2)

def fun3(x):
    return(x+3)

funs=[]
funs.append(fun0)
funs.append(fun1)
funs.append(fun2)
funs.append(fun3)

for i in range(0,4):
    print(funs[i](0.1*i))
