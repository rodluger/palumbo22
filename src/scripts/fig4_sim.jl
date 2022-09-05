# import stuff
using Distributed
using Pkg; Pkg.activate(".")
@everywhere using Pkg
@everywhere Pkg.activate(".")
using CSV
using GRASS; @everywhere using GRASS
using Statistics; @everywhere using Statistics
using EchelleCCFs; @everywhere using EchelleCCFs
using SharedArrays; @everywhere using SharedArrays
using JLD2
using FileIO

# showyourwork imports
@everywhere using PyCall
@everywhere begin
    py"""
    from showyourwork.paths import user as Paths

    paths = Paths()
    """
end

@everywhere datadir = py"""str(paths.data)""" * "/"

# define spec_loop function
include(GRASS.moddir * "figures/fig_functions.jl")

# some global stuff
const N = round.(Int, 2 .^ range(6, 10, step=0.5))
const Nt = 100
const Nloop = 24

function fig4()
    # set up parameters for lines
    lines = [5434.5]
    depths = [0.8]
    res = 700000.0
    top = NaN
    contiguous_only=true
    spec = SpecParams(lines=lines, depths=depths, resolution=res,
                      extrapolate=true, contiguous_only=contiguous_only)

    # allocate shared arrays
    avg_avg_res = SharedArray{Float64}(length(N))
    std_avg_res = SharedArray{Float64}(length(N))
    avg_rms_res = SharedArray{Float64}(length(N))
    std_rms_res = SharedArray{Float64}(length(N))

    # calculate
    @sync @distributed for i in 1:length(N)
    	println("running resolution N = " * string(N[i]))
        disk = DiskParams(N=N[i], Nt=Nt)
    	avg_avg1, std_avg1, avg_rms1, std_rms1 = spec_loop(spec, disk, Nloop, top=top)
        avg_avg_res[i] = avg_avg1
        std_avg_res[i] = std_avg1
    	avg_rms_res[i] = avg_rms1
    	std_rms_res[i] = std_rms1
    end

    # convert sharedarrays to plain arrays for writeout
    avg_avg_res = convert(Array{Float64}, avg_avg_res)
    std_avg_res = convert(Array{Float64}, std_avg_res)
    avg_rms_res = convert(Array{Float64}, avg_rms_res)
    std_rms_res = convert(Array{Float64}, std_rms_res)

    # write to file
    fname = datadir * "resolution_sim.jld2"
    save(fname,
         "res", N,
         "Nloop", Nloop,
         "avg_avg_res", avg_avg_res,
         "std_avg_res", std_avg_res,
         "avg_rms_res", avg_rms_res,
         "std_rms_res", std_rms_res)
    return nothing
end

# run the simulation
fig4()
