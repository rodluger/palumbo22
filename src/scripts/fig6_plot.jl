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
file = datadir * "inclination_sim.jld2"
data = load(file)
ang = data["incls"] .* (180.0/π)
Nloop = data["Nloop"]
avg_avg_inc = data["avg_avg_inc"]
std_avg_inc = data["std_avg_inc"]
avg_rms_inc = data["avg_rms_inc"]
std_rms_inc = data["std_rms_inc"]

# get the errors
err_avg_inc = std_avg_inc ./ sqrt(Nloop)
err_rms_inc = std_rms_inc ./ sqrt(Nloop)

# plot the results
fig = plt.figure()
ax1 = fig.add_subplot()
ax1.errorbar(ang, avg_rms_inc, yerr=err_rms_inc, capsize=3.0, color="black", fmt=".")
ax1.fill_between(ang, avg_rms_inc .- std_rms_inc, avg_rms_inc .+ std_rms_inc, color="tab:blue", alpha=0.3)

# annotate the axes
arrowprops = Dict("facecolor"=>"black", "shrink"=>0.05, "width"=>2.0,"headwidth"=>8.0)
ax1.annotate(L"\textnormal{Pole-on}", xy=(69.8, 0.39), xytext=(0.0,0.388), arrowprops=arrowprops)
ax1.annotate(L"\textnormal{Equator-on}", xy=(70.0, 0.388))

# set labels, etc.
ax1.set_xlabel(L"{\rm Inclination\ (deg)}")
ax1.set_ylabel(L"{\rm RMS}_{\rm RV}\ {\rm (m s}^{-1})")
ax1.set_xticks(range(0, 90, length=10))
ax1.set_ylim(0.375, 0.675)

# save the figure
fig.savefig(plotdir * "fig6.pdf")
plt.clf(); plt.close()
println(">>> Figure written to: " * plotdir * "fig6.pdf")

