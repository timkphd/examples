#!/usr/bin/env julia
# Simple Pendulum Problem
import OrdinaryDiffEq as ODE, Plots

#Constants
const g = 9.81
L = 1.0

#Initial Conditions
global u₀ = [0, π / 2]
global tspan = (0.0, 6.3)

#Define the problem
function simplependulum(du, u, p, t)
    θ, ω = u
    du[1] = ω
    du[2] = -(g / L) * sin(θ)
end


#Pass to solvers
prob = ODE.ODEProblem(simplependulum, u₀, tspan)
sol = ODE.solve(prob, ODE.Tsit5())

sol

p1=Plots.plot(sol, linewidth = 2, title = "Simple Pendulum Problem", xaxis = "Time",
    yaxis = "Height", label = ["\\theta" "d\\theta"])
Plots.savefig(p1,"Pendulum.pdf")
const g = 9.81
function gravity(du, u, p, t)
    θ, ω = u
    du[1] = ω
    du[2] = -g
end

u₀ = [0, 0]
tspan = (0.0, 1.0)
prob = ODE.ODEProblem(gravity, u₀, tspan)
sol = ODE.solve(prob)


tspan = (0.0, .1)
prob = ODE.ODEProblem(gravity, u₀, tspan)
sol = ODE.solve(prob)

sol.u[length(sol.u)]

my_t = Vector{Float64}()
my_v = Vector{Float64}()
my_d = Vector{Float64}()
dt=0.01
now=0.0
tspan = (0.0, dt)
u₀ = [0, 0]
push!(my_t,now)
push!(my_v,u₀[1])
push!(my_d,u₀[2])
now=dt
endt=1.0-1e-6
while now < endt
    local prob = ODE.ODEProblem(gravity, u₀, tspan)
    local sol = ODE.solve(prob)
    global now=tspan[2]
    #println(now,tspan,sol.u[length(sol.u)])
    push!(my_t,now)
    push!(my_v,sol.u[length(sol.u)][2])
    push!(my_d,sol.u[length(sol.u)][1])
    global tspan=(tspan[1]+dt,tspan[2]+dt)
    global u₀=sol.u[length(sol.u)]
end
p2=Plots.plot(my_t,my_d, linewidth = 2, title = "Gravity", xaxis = "Time",
    yaxis = "Height", label = "falling")
Plots.savefig(p2,"Gravity.pdf")
using Printf
for i in 1:length(my_t)
    @printf("%10.4f %10.4f%10.4f\n",my_t[i],my_v[i],my_d[i])
end


