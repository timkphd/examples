# utility output routines
def write_each(psi,i1, i2, j1, j2,nx,ny,comm):
	from numpy import empty
	from mpi4py import MPI
	myid=comm.Get_rank()
	numnodes=comm.Get_size()
	if(i1==1):
		i0=0
	else :
		i0=i1
	if(i2==nx):
		i3=nx+1
	else :
		i3=i2
	if(j1==1): 
		j0=0
	else :
		j0=j1
	if(j2==ny):
		j3=ny+1
	else :
		j3=j2
	fname="out"+str(myid)
	eighteen=open(fname,"w")
#	eighteen.write(str(psi))
#	eighteen.close()
#	return 0
	aline=("%d %d %d %d %d %d\n" % (i1, i2, j1, j2,nx,ny))
	eighteen.write(aline)
	aline=(str(psi.shape)+"\n")
	eighteen.write(aline)
	aline=("%d %d %d %d\n" % (i0, i3+1, j0, j3+1))
	eighteen.write(aline)
	eighteen.write(str(psi)+"\n")
	(imax,jmax)=(psi.shape)
	for i in range(0,imax) :
		for j in range(0,jmax) :
			vout=("%18.5f" % (psi[i][j]))
			eighteen.write(vout)
#			eighteen.write(str(psi[i][j]))
			if(j != jmax-1):
				eighteen.write(" ")
		eighteen.write("\n")
	eighteen.close()



def write_one(psi,i1,i2,j1,j2,nx,ny,comm):
# 1-d version -> every processor holds a portion of a line
	from numpy import empty,array
	from mpi4py import MPI
	myid=comm.Get_rank()
	numnodes=comm.Get_size()
	counts=None
	offsets=None
	arow=None
	(id,jd)=psi.shape
	if myid == 0 : 
		jstart=0
	else:
		jstart=1
	if myid == (numnodes-1) : 
		jend=jd
	else:
		jend=jd-1
	i0=0
	j0=0
	i3=nx+1
	j3=ny+1
	mpiwriter=numnodes-1
#	print(myid,jstart,jend)
#	mine=open(str(myid),"w")
	if(myid == mpiwriter) :
		eighteen=open("out3d","w")
		aline=(str(i0)+" <= i <= "+str(i3)+" , "+str(j0)+" <= j <= "+str(j3)+"\n")
		print(aline)
		eighteen.write(aline)
		arow=empty(j3+2,"d")
		counts=empty(numnodes,"i")
		offsets=empty(numnodes,"i")
		offsets[0]=0
	#endif
	for i in range(0,i3+1):
		dj=jend-jstart
		#endif
		#counts=comm.gather(dj)
		#Comm.Gather(self, sendbuf, recvbuf, int root=0)
		comm.Gather(sendbuf=[array(dj),1,MPI.INT], recvbuf=[counts,1,MPI.INT],root=mpiwriter)
		if(myid == mpiwriter):	
			for k in range(1,numnodes) :
				offsets[k]=counts[k-1]+offsets[k-1]
#			print(i,counts,offsets)
		#endif
#		mine.write(str(i)+" "+str(i)+" "+str(jstart)+" "+str(jend)+" "+str(psi[i,jstart:jend])+"\n")
		comm.Gatherv(sendbuf=[psi[i,jstart:jend], (dj),MPI.DOUBLE_PRECISION], recvbuf=[arow, (counts,offsets), MPI.DOUBLE_PRECISION],root=mpiwriter) 
		if(myid == mpiwriter):
			scounts=sum(counts)
			for j in range(0,scounts):
				vout=("%18.5f" % (arow[j]))
				eighteen.write(vout)
				if(j != scounts-1):
					eighteen.write(" ")
			eighteen.write("\n")
		#endif
	#endfor
	if(myid == mpiwriter): eighteen.close()
#	mine.close()




def write_extra(nx,ny,comm,count):
# 1-d version -> every processor holds a portion of a line
	from numpy import empty,array
	from mpi4py import MPI
	myid=comm.Get_rank()
	numnodes=comm.Get_size()
	counts=None
	offsets=None
	arow=None
	i3=nx+1
	j3=ny+1
	eighteen=open("out3d","w")
	aline=(str(0)+" <= i <= "+str(i3)+" , "+str(0)+" <= j <= "+str(j3)+"\n")
	print(aline)
	eighteen.write(aline)
	arow=empty(j3+2,"d")
	counts=empty(numnodes,"i")
	offsets=empty(numnodes,"i")
	mywriter=numnodes-1
	offsets[0]=0
	for i in range(0,i3+1):
		dj=0
		comm.Gather(sendbuf=[array(dj),1,MPI.INT], recvbuf=[counts,1,MPI.INT],root=mywriter)
		for k in range(1,numnodes) :
			offsets[k]=counts[k-1]+offsets[k-1]
		#endif
		comm.Gatherv(sendbuf=[None, (0),MPI.DOUBLE_PRECISION], recvbuf=[arow, (counts,offsets), MPI.DOUBLE_PRECISION],root=mywriter) 
		scounts=sum(counts)
		for j in range(0,scounts):
			vout=("%18.5f" % (arow[j]))
			eighteen.write(vout)
			if(j != scounts-1):
				eighteen.write(" ")
		eighteen.write("\n")
	eighteen.close()


def plot_extra(nx,ny,comm,count):
# 1-d version -> every processor holds a portion of a line
	from numpy import empty,array
	import numpy
	from mpi4py import MPI
	from mpl_toolkits.mplot3d import Axes3D
	from matplotlib import cm
	from matplotlib.ticker import LinearLocator, FormatStrFormatter
	import matplotlib.pyplot as plt
	import time
	import os
	myid=comm.Get_rank()
	numnodes=comm.Get_size()
	counts=None
	offsets=None
	arow=None
	i3=nx+1
	j3=ny+1
	gs=nx+3
	fig = plt.figure()
	ax = fig.gca(projection='3d')
	X = numpy.arange(1, gs, 1)
	Y = numpy.arange(1, gs, 1)
	X, Y = numpy.meshgrid(X, Y)
	R = numpy.sqrt(X**2 + Y**2)
	Z = R
	k=0
	print(Z.shape)

#	eighteen=open("out3d","w")
	aline=(str(0)+" <= i <= "+str(i3)+" , "+str(0)+" <= j <= "+str(j3)+"\n")
	print(aline)
#	eighteen.write(aline)
	arow=empty(j3+2,"d")
	counts=empty(numnodes,"i")
	offsets=empty(numnodes,"i")
	mywriter=numnodes-1
	offsets[0]=0
	for i in range(0,i3+1):
		dj=0
		comm.Gather(sendbuf=[array(dj),1,MPI.INT], recvbuf=[counts,1,MPI.INT],root=mywriter)
		for k in range(1,numnodes) :
			offsets[k]=counts[k-1]+offsets[k-1]
		#endif
		comm.Gatherv(sendbuf=[None, (0),MPI.DOUBLE_PRECISION], recvbuf=[arow, (counts,offsets), MPI.DOUBLE_PRECISION],root=mywriter) 
		scounts=sum(counts)
		for j in range(0,scounts):
#			vout=("%18.5f" % (arow[j]))
			Z[i][j]=arow[j]
#			eighteen.write(vout)
#			if(j != scounts-1):
#				eighteen.write(" ")
#		eighteen.write("\n")
#	eighteen.close()
#	surf = ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap=cm.rainbow,
#                       linewidth=0, antialiased=False)
	surf = ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap=cm.rainbow,
                       linewidth=0, antialiased=False,vmax=5e7)
#ax.set_zlim(0,256)
	ax.set_zlim(0,0.5e8)

	ax.zaxis.set_major_locator(LinearLocator(6))
#ax.zaxis.set_major_formatter(FormatStrFormatter('%.02f'))
	ax.zaxis.set_major_formatter(FormatStrFormatter('%3.2e'))

	fig.colorbar(surf, shrink=0.5, aspect=5)
	
	usebuiltin=False

	if usebuiltin : 
		plt.show()
		plt.close('all')
		plt=None
		time.sleep(2)
	else:
		dataf="out%4.4d_s.png" % (count)
		plt.savefig(dataf)
		plt.close()
		plt=None
#		command="open "+dataf
#		x=os.popen(command,"r")
#		x.readlines()
	#time.sleep(1)
	


