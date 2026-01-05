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



function do_jacobi(psi,new_psi,i1,i2,j1,j2)
# does a single Jacobi iteration step
# input is the grid and the indices for the interior cells
# new_psi is temp storage for the the updated grid
# output is the updated grid in psi and diff which is
# the sum of the differences between the old and new grids
    ldiff=0.0
    for i=i1:i2
        for j=j1:j2
#            y=j*dy
            new_psi[i,j]=a1*psi[i+1,j] + a2*psi[i-1,j] + a3*psi[i,j+1] + a4*psi[i,j-1] - a5*fors[i,j]
#                         a5*force[y]
            ldiff=ldiff+abs(new_psi[i,j]-psi[i,j])
         end
     end
    for i=i1:i2
        for j=j1:j2
           psi[i,j]=new_psi[i,j]
        end
    end
    return ldiff
end;



# get the input.  see above for typical values

nx=200
ny=200
lx=2000000.0
ly=2000000.0
alpha=1.0e-9
beta=2.25e-11
gamma=3.0e-6
steps=75000

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
bc(psi,i1,i2,j1,j2)
do_force(fors,i1,i2,j1,j2)
using Printf


st = time()
for istep=1:steps
 mydiff=do_jacobi(psi,new_psi,i1,i2,j1,j2)
 if mod(istep,steps/100) == 0 
     @printf("%8d %12.6e %10.4f\n",istep,mydiff,time()-st)
 end
end
et=time()
println("run time=",et-st)

