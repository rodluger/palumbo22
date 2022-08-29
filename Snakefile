rule fig1b:
    input:
        "src/scripts/fig1b.jl"
    output:
        "src/tex/figures/fig1b.pdf"
    shell:
        "julia src/scripts/fig1b.jl"
rule fig4:
    input:
        "src/scripts/fig4_sim.jl"
    output:
        "src/data/rms_vs_res.csv"
    cache:
        True
    shell:
        "julia src/scripts/fig4_sim.jl"

