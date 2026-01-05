#!/usr/bin/env julia

using OffsetArrays
function bc(psi,i1,i2,j1,j2)
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
end;


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



function do_jacobi(psi,new_psi,fors,i1,i2,j1,j2,a1,a2,a3,a4,a5)
# does a single Jacobi iteration step
# input is the grid and the indices for the interior cells
# new_psi is temp storage for the updated grid
# output is the updated grid in psi and diff which is
# the sum of the differences between the old and new grids
    ldiff=0.0
    for j=j1:j2
      for i=i1:i2
            new_psi[i,j]=a1*psi[i+1,j] + a2*psi[i-1,j] + a3*psi[i,j+1] + a4*psi[i,j-1] - a5*fors[i,j]
            ldiff=ldiff+abs(new_psi[i,j]-psi[i,j])
         end
     end
    #ldiff=sum(broadcast(abs,(new_psi-psi)))
    #ldiff=sum(abs.(new_psi-psi))
    psi[i1:i2,j1:j2]=new_psi[i1:i2,j1:j2]
    return ldiff
end;



# get the input.  typical values:
#200 200
#2000000 2000000
#1.0e-9 2.25e-11 3.0e-6
#75000


#z=split(readline())
z=["200" , "200"]
nx=parse(Int64,z[1])
ny=parse(Int64,z[2])

#z=split(readline())
z=["2000000" , "2000000"]
lx=parse(Float64,z[1])
ly=parse(Float64,z[2])

#z=split(readline())
z=["1.0e-9" ,"2.25e-11" ,"3.0e-6"]
alpha=parse(Float64,z[1])
beta=parse(Float64,z[2])
gamma=parse(Float64,z[3])

#z=split(readline())
z=["75000"]
steps=parse(Int64,z[1])

# allocate the grid to size nx * ny plus the boundary cells
psi=OffsetArray{Float64}(undef, 0:nx+1,0:ny+1)
new_psi=OffsetArray{Float64}(undef, 0:nx+1,0:ny+1)
fors=OffsetArray{Float64}(undef, 0:nx+1,0:ny+1)


# calculate the constants for the calculations
dx=lx/(nx+1)
dy=ly/(ny+1)
dx2=dx*dx
dy2=dy*dy
bottom=2.0*(dx2+dy2)
a1=(dy2/bottom)+(beta*dx2*dy2)/(2.0*gamma*dx*bottom)
a2=(dy2/bottom)-(beta*dx2*dy2)/(2.0*gamma*dx*bottom)
a3=dx2/bottom
a4=dx2/bottom
a5=dx2*dy2/(gamma*bottom)
a6=pi/(ly)

# set initial guess for the value of the grid
fill!(psi,1.0)

# set the indices for the interior of the grid
i1=1
i2=nx
j1=1
j2=ny


# set boundary conditions
@time bc(psi,i1,i2,j1,j2)
@time do_force(fors,i1,i2,j1,j2)
using Printf


function doit(psi,new_psi,fors,a1,a2,a3,a4,a5)
st = time()
for istep=1:steps
 mydiff=do_jacobi(psi,new_psi,fors,i1,i2,j1,j2,a1,a2,a3,a4,a5)
 if mod(istep,steps/100) == 0 
     @printf("%8d %12.6e %10.4f\n",istep,mydiff,time()-st)
 end
end
et=time()
println("run time=",et-st)

end;

@time doit(psi,new_psi,fors,a1,a2,a3,a4,a5)
