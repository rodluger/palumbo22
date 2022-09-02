# import stuff
using Distributed
@everywhere using Pkg
@everywhere Pkg.activate(".")
@everywhere using GRASS
@everywhere using Statistics
@everywhere using EchelleCCFs
@everywhere using SharedArrays
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

function main()
    # set up stuff for lines
    lines = [5434.5]
    depths = [0.8]
    resolution = 700000.0
    top = NaN
    contiguous_only=false

    # get angles
    n_inc = 20
    incls = (π/180.0) .* range(0.0, 90.0, length=n_inc)
    ycomp = sin.(incls)
    zcomp = cos.(incls)

    # make pole vectors
    poles = Array{Tuple{Float64, Float64, Float64}, 1}(undef, n_inc)
    for i in eachindex(incls)
        pole = (0.0, ycomp[i], zcomp[i])
        poles[i] = pole
    end

    # allocate shared sharred arrays
    avg_avg_inc = SharedArray{Float64}(n_inc)
    std_avg_inc = SharedArray{Float64}(n_inc)
    avg_rms_inc = SharedArray{Float64}(n_inc)
    std_rms_inc = SharedArray{Float64}(n_inc)

    # loop over inclinations
    @sync @distributed for i in eachindex(poles)
        println("running pole " * string(i) * " of " * string(n_inc))

         # create spec and disk params instances
        spec = SpecParams(lines=lines, depths=depths, resolution=resolution,
                          extrapolate=true, contiguous_only=contiguous_only)
        disk = DiskParams(N=N, Nt=Nt, pole=poles[i])

        # synthesize spectra, get velocities and stats
        avg_avg1, std_avg1, avg_rms1, std_rms1 = spec_loop(spec, disk, Nloop, top=top)
        avg_avg_inc[i] = avg_avg1
        std_avg_inc[i] = std_avg1
        avg_rms_inc[i] = avg_rms1
        std_rms_inc[i] = std_rms1
    end

    # write results to file
    fname = datadir * "inclination_sim.jld2"
    save(fname,
         "Nloop", Nloop,
         "incls", incls,
         "avg_avg_inc", avg_avg_inc,
         "std_avg_inc", std_avg_inc,
         "avg_rms_inc", avg_rms_inc,
         "std_rms_inc", std_rms_inc)
    return nothing
end

# run the simulation
main()

