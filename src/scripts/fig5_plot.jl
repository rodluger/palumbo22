# import stuff
using Pkg; Pkg.activate("."); Pkg.instantiate()
using JLD2
using GRASS
using LsqFit
using FileIO
using Statistics
using EchelleCCFs

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
file = datadir * "depth_sim.jld2"
data = load(file)
Nloop = data["Nloop"]
depths = data["depth"]
avg_avg_depth = data["avg_avg_depth"]
std_avg_depth = data["std_avg_depth"]
avg_rms_depth = data["avg_rms_depth"]
std_rms_depth = data["std_rms_depth"]

# get the errors
err_avg_depth = std_avg_depth ./ sqrt(Nloop)
err_rms_depth = std_rms_depth ./ sqrt(Nloop)

# plot the results
fig, ax1 = plt.subplots()
ax1.errorbar(depths, avg_rms_depth, yerr=err_rms_depth, capsize=3.0, color="black", fmt=".")
ax1.fill_between(depths, avg_rms_depth .- std_rms_depth, avg_rms_depth .+ std_rms_depth, color="tab:blue", alpha=0.3)
ax1.fill_betweenx(range(0.0, 1.0, length=5), zeros(5), zeros(5) .+ 0.2, hatch="/", fc="black", ec="white", alpha=0.15, zorder=0)

# set labels, etc.
ax1.set_xlabel(L"{\rm Line\ Depth}")
ax1.set_ylabel(L"{\rm RMS}_{\rm RV}\ {\rm (m s}^{-1})")
ax1.set_xlim(0.0, 1.0)
ax1.set_ylim(0.375, 0.675)

# annotate the axes and save the figure
arrowprops = Dict("facecolor"=>"black", "shrink"=>0.05, "width"=>2.0,"headwidth"=>8.0)
ax1.annotate(L"{\rm Shallow}", xy=(0.85,0.39), xytext=(0.05,0.388), arrowprops=arrowprops)
ax1.annotate(L"{\rm Deep}", xy=(0.86, 0.388))
fig.savefig(plotdir * "fig5.pdf")
plt.clf(); plt.close()
println(">>> Figure written to: " * plotdir * "fig5.pdf")



