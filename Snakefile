rule fig2:
    input:
        "src/scripts/fig2.jl"
    output:
        "src/tex/figures/fig2a.pdf"
        "src/tex/figures/fig2b.pdf"
    shell:
        "julia src/scripts/fig2.jl"

rule fig3:
    input:
        "src/scripts/fig3.jl"
    output:
        "src/tex/figures/fig3a.pdf"
        "src/tex/figures/fig3b.pdf"
    shell:
        "julia src/scripts/fig3.jl"

# rule fig4:
#     input:
#         "src/scripts/fig4_sim.jl"
#     output:
#         "src/data/rms_vs_res.csv"
#     cache:
#         True
#     shell:
#         "julia src/scripts/fig4_sim.jl"

