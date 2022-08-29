rule fig1b:
    input:
        "src/static/fig1a.pdf"
        "src/scripts/fig1b.jl"
    output:
        "src/tex/figures/fig1a.pdf"
        "src/tex/figures/fig1b.pdf"
    shell:
        "julia src/scripts/fig1b.jl"

