#!/usr/bin/env julia

A = [1 2 3; 4 1 6; 7 8 1]
y=[5,3,4]
x=A\y
A*x

function gauss_jordan(A::Matrix{T}) where {T<:Number}
    
    # convert to float to avoid InexactError: Int64()
    (T <: Integer) && (A = convert.(Float64, A))

    m, n = size(A)

    for i ∈ axes(A, 1)
        if A[i,i] == 0.0                            # check if need swap rows
            swap_rows(i, m)
        end

        @. A[i,:] = A[i,:] / A[i,i]                 # divide pivot line by pivot element

        for j ∈ axes(A, 1)                          # iterate each line for each pivot column, except pivot line
            if j ≠ i                                # jump pivot line
                @. A[j,:] = A[j,:] - A[i,:]*A[j,i]  # apply gauss jordan in each line
            end
        end
    end

    return A[:,n]
end

function gauss_jordan(A::Matrix{T},B::Vector{T}) where {T<:Number}
    
    # convert to float to avoid InexactError: Int64()
    (T <: Integer) && (A = convert.(Float64, A))
    (T <: Integer) && (B = convert.(Float64, B))
    A = [A B]

    m, n = size(A)

    for i ∈ axes(A, 1)
        if A[i,i] == 0.0                            # check if need swap rows
            swap_rows(i, m)
        end

        @. A[i,:] = A[i,:] / A[i,i]                 # divide pivot line by pivot element

        for j ∈ axes(A, 1)                          # iterate each line for each pivot column, except pivot line
            if j ≠ i                                # jump pivot line
                @. A[j,:] = A[j,:] - A[i,:]*A[j,i]  # apply gauss jordan in each line
            end
        end
    end

    return A[:,n]
end

function swap_rows(i::T, nlinha::T) where {T<:Integer}
    for n ∈ (i+1):nlinha        # iterate over lines above to check if could be swap
        if A[n,i] ≠ 0.0         # condition to swap row
            L = copy(A[i,:])    # copy line to swap
            A[i,:] = A[n,:]     # swap occur
            A[n,:] = L
            break
        end
    end
end

bonk=[1 2 3 3; 4 1 6 7; 7 8 1 8]

gb=gauss_jordan(bonk)

z=bonk[1:3,1:3]

back1=gauss_jordan(z,[3; 7; 8])

back1

println(z*back1)

msize=1000
using Random
Random.seed!(42)
t1=time()
for i in 1:4
    global back
    a=rand(msize,msize)
    b=rand(msize)
    @time back=gauss_jordan(a,b)
end
mine=back
t2=time()
mytime=t2-t1
println(t2-t1)
Random.seed!(42)
t1=time()
for i in 1:4
	global back
    a=rand(msize,msize)
    b=rand(msize)
    @time back=a\b
end
hers=back
t2=time()
jtime=t2-t1
println(t2-t1)
println(mytime/jtime)

println("error: ",(sum((mine-hers).^2)^0.5)/msize)


