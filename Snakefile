# rule fig4:
#     input:
#         "src/scripts/fig4_sim.jl"
#     output:
#         "src/data/rms_vs_res.csv"
#     cache:
#         True
#     shell:
#         "julia src/scripts/fig4_sim.jl"

