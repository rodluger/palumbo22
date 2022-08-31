# import stuff
using Distributed
@everywhere using Pkg;
@everywhere Pkg.activate(".");
@everywhere using CSV
@everywhere using GRASS
@everywhere using LsqFit
@everywhere using DataFrames
@everywhere using Statistics
@everywhere using EchelleCCFs
@everywhere using SharedArrays

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

function main()
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

    # make data frame
    df = DataFrame()
    df[!,:res] = N
    df[!,:Nloop] = Nloop
    df[!,:avg_avg_res] = avg_avg_res
    df[!,:std_avg_res] = std_avg_res
    df[!,:avg_rms_res] = avg_rms_res
    df[!,:std_rms_res] = std_rms_res

    # write to CSV
    fname = datadir * "rms_vs_res.csv"
    CSV.write(fname, df)
    return nothing
end

# run the simulation
main()
