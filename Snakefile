rule fig1b:
    input:
        "src/scripts/fig1b.jl"
    output:
        "src/static/fig1a.pdf"
        "src/tex/figures/fig1b.pdf"
    shell:
        "julia src/scripts/fig1b.jl"

