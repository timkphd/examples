class aboard:
	"""A simple example class"""
	full = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
	_registry = []
	def f(self):
		return self.pied   
	def __init__(self, open=-1,fill=[]):
		self._registry.append(self)
		self.pied=board.full
		if(open > -1) :
			self.pied[open]=0
		if(len(fill)== 15):
			self.pied=fill
	def delete(self):
		MyClass._registry.remove(self)
		return None

#
#from board import *
#x=board(open=9)
#y=board(fill=[1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])

sets=[[[ 1, 3],[ 2, 5]]
     ,[[ 3, 6],[ 4, 8]]
     ,[[ 4, 7],[ 5, 9]]
     ,[[ 1, 0],[ 4, 5],[ 6,10],[ 7,12]]
     ,[[ 7,11],[ 8,13]]
     ,[[ 2, 0],[ 4, 3],[ 8,12],[ 9,14]]
     ,[[ 3, 1],[ 7, 8]]
     ,[[ 4, 2],[ 8, 9]]
     ,[[ 4, 1],[ 7, 6]]
     ,[[ 5, 2],[ 8, 7]]
     ,[[ 6, 3],[11,12]]
     ,[[ 7, 4],[12,13]]
     ,[[ 7, 3],[ 8, 5],[11,10],[13,14]]
     ,[[ 8, 4],[12,11]]
     ,[[ 9, 5],[13,12]]]
tried={}
def domoves(Filled):
	moves=[]  
	for i in [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]:
		if Filled[i] == 0:
			curset=sets[i]
			for s in curset:
				t1=s[0]
				t2=s[1]
				if(Filled[t1]==1  and Filled[t2]==1):
					moves.append([i,t1,t2])
	return moves
def newfill(oldfill,move):
	import copy
	tmp=copy.copy(oldfill)
	tmp[move[0]]=1
	tmp[move[1]]=0
	tmp[move[2]]=0
	return tmp
def values(z1):
	z2=list(range(0,15))
	z3=list(range(0,15))
	z2[ 0]=z1[14]
	z2[ 1]=z1[ 9]
	z2[ 2]=z1[13]		
	z2[ 3]=z1[ 5]
	z2[ 4]=z1[ 8]
	z2[ 5]=z1[12]		
	z2[ 6]=z1[ 2]
	z2[ 7]=z1[ 4]
	z2[ 8]=z1[ 7]		
	z2[ 9]=z1[11]
	z2[10]=z1[ 0]
	z2[11]=z1[ 1]		
	z2[12]=z1[ 3]
	z2[13]=z1[ 6]
	z2[14]=z1[10]
			
	z3[ 0]=z1[10]
	z3[ 1]=z1[11]
	z3[ 2]=z1[ 6]		
	z3[ 3]=z1[12]
	z3[ 4]=z1[ 7]
	z3[ 5]=z1[ 3]		
	z3[ 6]=z1[13]
	z3[ 7]=z1[ 8]
	z3[ 8]=z1[ 4]	
	z3[ 9]=z1[ 1]
	z3[10]=z1[14]
	z3[11]=z1[ 9]		
	z3[12]=z1[ 5]
	z3[13]=z1[ 2]
	z3[14]=z1[ 0]
	t1=0
	t2=0
	t3=0		
	p=1
	for i in range(0,15):
		t1=t1+p*z1[i]
		t2=t2+p*z2[i]
		t3=t3+p*z3[i]
		p=p*2
	return t1,t2,t3

def pegs(fill):
	i=0
	for j in fill:
		i=i+j
	return i

def values(z1):
	map1=list(range(0,15))
	map2=[14,9,13,5,8,12,2,4,7,11,0,1,3,6,10]
	map3=[10,11,6,12,7,3,13,8,4,1,14,9,5,2,0]
	map4=[0,2,1,5,4,3,9,8,7,6,14,13,12,11,10]
	maps=[map1,map2,map3,map4]
	t=[0,0,0,0]
	p=1
	it=0
	for i in range(0,15):
		it=0
		for map in maps:
			t[it]=t[it]+p*z1[map[i]]
			it=it+1
		p=p*2
	return t


#					0 0
#				1 2		2 1
#			3 5		4 4		5 3
#		6 9		7 8		8 7		9 6
#	10 14	11 13	12 12	13 11	14 10
ncall=0
nocall=0
solution=[]
tries={}       
def dig(fill):
	global ncall,solution,tries,nocall
	np=pegs(fill)
#	print np
	ncall=ncall+1
	if (np > 1):
		moves=domoves(fill)
		if( len(moves) > 0):
			for m in moves:
				nextb=newfill(fill,m)
				dotest=True
				v=values(nextb)
				for t in v:
					if(t in tries) :
						dotest=False
						nocall=nocall+1
				for t2 in v:
					tries[t2]=''
				if(dotest):
					done=dig(nextb)
				else:
					done=False
				if(done):
					#print fill
					solution.append(fill)
					#print solution
					return True
	else:
#		print "found solution"
		#print fill
		solution.append(fill)
		#print solution
		return True
def printit(sol):
	import copy
	x=copy.copy(sol)
	x.reverse()
	for s in x:
		print() 
		print("     %1d"% (s[0]))
		print("    %1d %1d" %(s[1],s[2]))
		print("   %1d %1d %1d"%(s[3],s[4],s[5]))
		print("  %1d %1d %1d %1d"%(s[6],s[7],s[8],s[9]))
		print(" %1d %1d %1d %1d %1d"%(s[10],s[11],s[12],s[13],s[14]))

def doit(fill,report=False):
	global ncall,solution,nocall
	ncall=0
	solution=[]
	tries={}
	dig(fill)
	if report : print("boards evaluated:",ncall,"      repeats skipped:",nocall)
#	print "solution is:"
#	printit(solution)
	return solution

def calls():
	global ncall
	return ncall,nocall

def reset():
	global ncall,solution,tries,nocall
	ncall=0
	nocall=0
	solution=[]
	tries={}
	
def getmove(oldb,newb):
		new0=[]
		new1=[]
		amove=[]
#		print oldb
#		print newb
		for i in range(0,15):
			if (oldb[i] != newb[i]):
					if (newb[i] == 1):
						new1.append(i)
					else:
						new0.append(i)
		if (len(new1) != 1) or (len(new0) != 2) :
			print("no valid move between")
			print(oldb)
			print(newb)
			return amove
		moveset=sets[new1[0]]
		for m in moveset:
			if m.__contains__(new0[0]) and m.__contains__(new0[1]) :
				return [m[1],m[0],new1[0]]
						
def wtf(oldb,newb):
	print(oldb)
	print(newb)

afill=[1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
