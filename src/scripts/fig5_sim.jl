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
const N = 132
const Nt = 200
const Nloop = 200

function fig5()
    # set up parameters for lines
    lines = [5434.5]
    depths = range(0.05, stop=0.95, step=0.05)
    resolution=700000.0
    top = NaN
    contiguous_only=false

    # allocate shared arrays
    avg_avg_depth = SharedArray{Float64}(length(depths))
    std_avg_depth = SharedArray{Float64}(length(depths))
    avg_rms_depth = SharedArray{Float64}(length(depths))
    std_rms_depth = SharedArray{Float64}(length(depths))

    # loop over depths
    disk = DiskParams(N=N, Nt=Nt)
    @sync @distributed for i in eachindex(depths)
        println("running depth = " * string(depths[i]))

        # create spec instance
        spec = SpecParams(lines=lines, depths=[depths[i]], resolution=resolution,
                          extrapolate=true, contiguous_only=contiguous_only)

        # synthesize spectra, get velocities and stats
        avg_avg1, std_avg1, avg_rms1, std_rms1 = spec_loop(spec, disk, Nloop, top=top)
        avg_avg_depth[i] = avg_avg1
        std_avg_depth[i] = std_avg1
        avg_rms_depth[i] = avg_rms1
        std_rms_depth[i] = std_rms1
    end

    # convert sharedarrays to plain arrays for writeout
    depths = convert(Array{Float64}, depths)
    avg_avg_depth = convert(Array{Float64}, avg_avg_depth)
    std_avg_depth = convert(Array{Float64}, std_avg_depth)
    avg_rms_depth = convert(Array{Float64}, avg_rms_depth)
    std_rms_depth = convert(Array{Float64}, std_rms_depth)

    # write to file
    fname = datadir * "depth_sim.jld2"
    save(fname,
         "Nloop", Nloop,
         "depths", depths,
         "avg_avg_depth", avg_avg_depth,
         "std_avg_depth", std_avg_depth,
         "avg_rms_depth", avg_rms_depth,
         "std_rms_depth", std_rms_depth)
    return nothing
end

# run the simulation
fig5()

