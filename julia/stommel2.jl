#!/usr/bin/env julia
using Profile
#= 
nx,ny=parse.(Int64,split(readline()))
lx,ly=parse.(Float64,split(readline()))
alpha,beta,gamma=parse.(Float64,split(readline()))
steps=parse.(Int64,split(readline()))
=#
nx,ny=parse.(Int64,split("10 10"))
nx,ny=parse.(Int64,split("200 200"))

lx,ly=parse.(Float64,split("2000000 2000000"))
alpha,beta,gamma=parse.(Float64,split("1.0e-9 2.25e-11 3.0e-6"))
steps=parse.(Int64,"75000")

using OffsetArrays


    dx=lx/(nx+1)
    dy=ly/(ny+1)
    dx2=dx*dx
    dy2=dy*dy
    bottom=2.0*(dx2+dy2)
    const a1=(dy2/bottom)+(beta*dx2*dy2)/(2.0*gamma*dx*bottom)
    const a2=(dy2/bottom)-(beta*dx2*dy2)/(2.0*gamma*dx*bottom)
    const a3=dx2/bottom
    const a4=dx2/bottom
    const a5=dx2*dy2/(gamma*bottom)
    const a6=pi/(ly)


    i1=1
    i2=nx
    j1=1
    j2=ny


function bc!(psi,i1,i2,j1,j2)
    for k=j1-1:j2+1
        psi[i1-1,k]=0.0
        psi[i2+1,k]=0.0
    end
    for k=i1-1:i2+1
        psi[k,j1-1]=0.0
        psi[k,j2+1]=0.0
    end
end

function bc_x!(psi,i1,i2,j1,j2)
  e1=@view psi[i1-1,:]
  e2=@view psi[i2+1,:]
  e3=@view psi[:,j1-1]
  e4=@view psi[:,j2+1]
  fill!(e1, 0)
  fill!(e2, 0)
  fill!(e3, 0)
  fill!(e4, 0)
  end;

function force(y)
    force=-alpha*sin(y*a6)
end 

function do_force_org(theforce,i1,i2,j1,j2)
# sets the force conditions
# input is the grid and the indices for the interior cells
    for i=i1:i2
        for j=j1:j2
            y=j*dy
            #theforce[i,j]=force(y)
            # so it prints the same as fortran...
            theforce[j,i]=force(y)
            #theforce[j,i]=force(y)
            end
        end
end 

function do_force(forc,i1,i2,j1,j2)
# sets the force conditions
# input is the grid and the indices for the interior cells
    for i=i1:i2
        for j=j1:j2
            y=j*dy
            forc[i,j]=force(y)
        end
    end
end;


function do_jacobi(psi::OffsetMatrix{Float64, Matrix{Float64}},new_psi::OffsetMatrix{Float64, Matrix{Float64}},diff,i1,i2,j1,j2,theforce::OffsetMatrix{Float64, Matrix{Float64}})
	ldiff=0.0
	for j=j1:j2
		for i=i1:i2
			new_psi[i,j]=a1*psi[i+1,j] + a2*psi[i-1,j] + a3*psi[i,j+1] + a4*psi[i,j-1] - a5*theforce[i,j]
			ldiff=ldiff+abs(new_psi[i,j]-psi[i,j])
		end
	end
	psi.=new_psi

	diff[1]=ldiff
        return nothing
end

using Printf
function main()
psi = OffsetArray(ones(nx+2, ny+2), 0:nx+1, 0:ny+1)
# set initial guess for the value of the grid
fill!(psi,1.0)

new_psi = OffsetArray(zeros(nx+2, ny+2), 0:nx+1, 0:ny+1)
theforce = OffsetArray(zeros(nx+2, ny+2), 0:nx+1, 0:ny+1)
do_force(theforce,i1,i2,j1,j2)
#println(theforce)
#println("***************")
bc!(psi,i1,i2,j1,j2)
diff=[0.0]
iout=steps/100
st = time()
for i=1:steps
    do_jacobi(psi,new_psi,diff,i1,i2,j1,j2,theforce)
    if (mod(i,iout) == 0)
	@printf("%8d %12.6e %10.4f\n",i,diff[1],time()-st)
    end
end

et=time()
println("run time=",et-st)
end

main()

