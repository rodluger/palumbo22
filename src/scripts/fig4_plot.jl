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
file = datadir * "resolution_sim.jld2"
data = load(file)
res = data["res"]
Nloop = data["Nloop"]
rms_res = data["avg_rms_res"]
std_res = data["std_rms_res"]

# get the error
err_res = std_res ./ sqrt(Nloop)

# fit the data
@. power_law(x, p) = p[1] * x^(-p[2])
fit = curve_fit(power_law, res, rms_res, [1.0, 1.0])
res_fit = range(6, 2400, length=1000)
println(">>> Best fit power law index = " * string(fit.param[2]))
x = string(round(fit.param[2], sigdigits=2))

# initialize figure and set log scales
fig = plt.figure()
ax1 = fig.add_subplot()
ax1.set_xscale("log", base=2)
# ax1.set_yscale("log", base=10)

# plot the data
ax1.errorbar(res, rms_res, yerr=err_res, capsize=3.0, color="black", fmt=".")
ax1.plot(res_fit, power_law(res_fit, fit.param), "k--", alpha=0.4,
         label = L"{\rm Power\ law\ index\ } \approx\ %$x ")

# add a line corresponding to average footprint area
ax1.axvline(132, ymin=0, ymax=1, color="black", lw=1.5, ls="--")

# plot the literature values
xrng = ax1.get_xlim()
xs = range(xrng[1], xrng[2], length=2)
Elsworth = [repeat([0.319-0.09], 2), repeat([0.319+0.09], 2)]
Palle = [repeat([0.461-0.1], 2), repeat([0.461+0.1], 2)]
ax1.fill_between(xs, Elsworth..., alpha=0.5, fc="tab:orange", ec="white",
                 hatch="/", label=L"{\rm Elsworth\ et\ al.\ (1994)}")
ax1.fill_between(xs, Palle..., alpha=0.5, fc="tab:green", ec="white",
                 hatch="\\", label=L"\textnormal{Pall\'{e}}\ {\rm et\ al.\ (1999)}")

# set the axes limits + labels
ax1.set_xlim(2^5.9, 2^10.1)
ax1.set_ylim(0.01, 1.15)
ax1.yaxis.set_major_formatter(mpl.ticker.ScalarFormatter())
ax1.set_xlabel(L"N")
ax1.set_ylabel(L"{\rm RMS}_{\rm RV}\ {\rm (m s}^{-1})")
ax1.legend()

# save the figure
fig.savefig(plotdir * "fig4.pdf")
plt.clf(); plt.close()
println(">>> Figure written to: " * plotdir * "fig4.pdf")
