using Plots

f = (x, y) -> x^2 + y^2

x = range(-1, 1; length=100)
y = range(-2, 2; length=400)
z = fill(NaN, size(y, 1), size(x, 1))

for i in eachindex(x), j in eachindex(y)
    z[j, i] = f(x[i], y[j])
end
heatmap(x, y, z)

function read_2d_binary(filename::String, rows::Int, cols::Int, dtype::Type)
    # Create an uninitialized 2D array (Matrix) of the specified type and dimensions.
    # Julia's column-major memory layout naturally handles sequential binary reads.
    data = Matrix{dtype}(undef, rows, cols)

    # Open the file in read mode ("r") using a do block for automatic closing
    open(filename, "r") do io
        # Read the binary data from the stream 'io' and fill the 'data' array
        read!(io, data)
    end

    return data
end

org=read_2d_binary("psi.dat",202,202,Float64)


x = range(-1, 1; length=202)
y = range(-1, 1; length=202)
maxorg=maximum(org)
org=org/maxorg
porg=heatmap(x, y, org)
Plots.savefig(porg,"Original.pdf")


dat=read_2d_binary("aahost.dat",200,200,Float32)
x = range(-1, 1; length=200)
y = range(-1, 1; length=200)
maxdat=maximum(dat)
dat=dat/maxdat
pnew=heatmap(x, y, dat)
Plots.savefig(pnew,"concur.pdf")

using Printf
@printf("%10.4e %10.4e",maxorg,maxdat)




