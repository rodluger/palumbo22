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
const Nloop = 2400

function main()
    # set observing parameters
    N_obs = range(2, 4, step=1)  # number of observations
    exp_time = 600.0             # ~2 p-mode periods
    snr = 5000.0                 # SNR per res element to get 50 cm/s precision
    new_res = 1.17e5

    # dead times
    short_dead = 30.0            # representative for NEID read-out time
    large_dead = 3600.0          # ~60 mins

    # set up parameters for spectrum
    lines = [5434.5]
    depths = [0.8]
    resolution = 7e5

    # allocate shared arrays for short off-target time
    avg_shortdead = SharedArray{Float64}(length(N_obs), Nloop)
    rms_shortdead = SharedArray{Float64}(length(N_obs), Nloop)

    # allocate shared arrays for large off-target time
    avg_largedead = SharedArray{Float64}(length(N_obs), Nloop)
    rms_largedead = SharedArray{Float64}(length(N_obs), Nloop)

    # create spec params instance
    spec1 = SpecParams(lines=lines, depths=depths, resolution=resolution)

    # loop over number of observations
    for i in eachindex(N_obs)
        # create observation plan instances
        obs_shortdead = GRASS.ObservationPlan(N_obs=N_obs[i],
                                              obs_per_night=N_obs[i],
                                              time_per_obs=exp_time,
                                              dead_time=short_dead)
        obs_largedead = GRASS.ObservationPlan(N_obs=N_obs[i],
                                              obs_per_night=N_obs[i],
                                              time_per_obs=exp_time,
                                              dead_time=large_dead)

        # compute vels repeatedly to get good stats
        @sync @distributed for j in 1:Nloop
            # first simulate short off-target time
            rvs1, sigs1 = GRASS.simulate_observations(obs_shortdead, spec1, N=N, snr=snr, new_res=new_res)
            avg_shortdead[i, j] = mean(rvs1)
            rms_shortdead[i, j] = calc_rms(rvs1)


            # then simulate large off-target time
            rvs2, sigs2 = GRASS.simulate_observations(obs_largedead, spec1, N=N, snr=snr, new_res=new_res)
            avg_largedead[i, j] = mean(rvs2)
            rms_largedead[i, j] = calc_rms(rvs2)
        end
    end

    # convert sharedarrays to plain arrays for writeout
    avg_shortdead = convert(Array{Float64}, avg_shortdead)
    rms_shortdead = convert(Array{Float64}, rms_shortdead)
    avg_largedead = convert(Array{Float64}, avg_largedead)
    rms_largedead = convert(Array{Float64}, rms_largedead)

    # save the output
    fname = datadir * "observation_sim.jld2"
    save(fname,
         "avg_shortdead", avg_shortdead,
         "rms_shortdead", rms_shortdead,
         "avg_largedead", avg_largedead,
         "rms_largedead", rms_largedead,
         "exp_time", exp_time,
         "depths", depths,
         "N_obs", N_obs,
         "snr", snr)
    return nothing
end

# run the simulation
main()
