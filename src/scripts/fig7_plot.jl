# import stuff
using Pkg; Pkg.activate("."); Pkg.instantiate()
using JLD2
using GRASS
using LsqFit
using FileIO
using Statistics
using EchelleCCFs
using HypothesisTests

# showyourwork imports
using PyCall
py"""
from showyourwork.paths import user as Paths

paths = Paths()
"""

py"""
import os
from pathlib import Path
os.environ["PATH"] += os.pathsep + str(Path.home() / "bin")
"""

# plotting imports
using LaTeXStrings
import PyPlot; plt = PyPlot; mpl = plt.matplotlib; plt.ioff()
mpl.style.use(py"""str(paths.scripts)""" * "/fig.mplstyle")

# define directories
const plotdir = py"""str(paths.figures)""" * "/"
const datadir = py"""str(paths.data)""" * "/"
const staticdir = py"""str(paths.static)""" * "/"

# read in the data
file = datadir * "observation_sim.jld2"
data = load(file)
avg_shortdead = data["avg_shortdead"]
rms_shortdead = data["rms_shortdead"]
avg_largedead = data["avg_largedead"]
rms_largedead = data["rms_largedead"]
exp_time = data["exp_time"]
depths = data["depths"]
N_obs = data["N_obs"]
snr = data["snr"]

# initialize plotting objects
fig = plt.figure(figsize=(10.5, 6.75))
ax1 = plt.subplot2grid((2,4),(0,0), colspan=2)
ax2 = plt.subplot2grid((2,4),(0,2), colspan=2)
ax3 = plt.subplot2grid((2,4),(1,1), colspan=2)
axs = [ax1, ax2, ax3]

# make arrays for limits and loop over plotting windows
xlims = []
ylims = []
for i in eachindex(axs)
    # histogram for short dead time
    axs[i].hist(avg_shortdead[i,:], density=true, histtype="stepfilled", fc="k", ec="k", lw=2, alpha=0.5, label="Short wait")
    axs[i].hist(avg_shortdead[i,:], density=true, histtype="step", ec="k", lw=1.0, alpha=0.8)

    # histogram for long wait time
    axs[i].hist(avg_largedead[i,:], density=true, histtype="stepfilled", fc="tab:blue", ec="tab:blue", lw=1.5, alpha=0.5, label="Long wait")
    axs[i].hist(avg_largedead[i,:], density=true, histtype="step", ec="tab:blue", lw=1.5, alpha=0.8)

    # get axis limits
    append!(xlims, [axs[i].get_xlim()])
    append!(ylims, [axs[i].get_ylim()])

    # report two-sample KS test
    @show(ApproximateTwoSampleKSTest(avg_shortdead[i,:], avg_largedead[i,:]))
    println()
end

# set the axes limits
bbox = Dict("ec"=>"black", "fc"=>"white")
xy = (maximum(last.(xlims)) - 0.25, maximum(last.(ylims)) - 0.4)
for i in eachindex(axs)
    # annotate axes and set labels, etc.
    axs[i].annotate(L"N_{\rm obs} =\ " * latexstring(N_obs[i]), xy=xy, bbox=bbox)
    axs[i].set_xlabel(L"{\rm Mean\ velocity\ (m s}^{-1})")
    axs[i].set_ylabel(L"{\rm Probability\ density}")
    axs[i].set_xlim(round(minimum(first.(xlims)), digits=1),
                    round(maximum(last.(xlims)), digits=1))
    axs[i].set_ylim(minimum(first.(ylims)), maximum(last.(ylims)))
    axs[i].xaxis.set_major_locator(mpl.ticker.MaxNLocator(5))
end

# set legend in one panel and write figure
axs[1].legend(loc="upper left")
fig.savefig(plotdir * "fig7.pdf")
plt.clf(); plt.close()
println(">>> Figure written to: " * plotdir * "fig7.pdf")
