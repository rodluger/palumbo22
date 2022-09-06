## *GRASS: Distinguishing Planet-induced Doppler Signatures from Granulation with a Synthetic Spectra Generator* (Palumbo et al. 2022)
<a href="https://github.com/palumbom/palumbo22/actions/workflows/build.yml"><img src="https://github.com/palumbom/palumbo22/actions/workflows/build.yml/badge.svg?branch=main" alt="Article status"/></a>
<a href="https://github.com/palumbom/palumbo22/raw/main-pdf/arxiv.tar.gz"><img src="https://img.shields.io/badge/article-tarball-blue.svg?style=flat" alt="Article tarball"/></a>
<a href="https://github.com/palumbom/palumbo22/raw/main-pdf/ms.pdf"><img src="https://img.shields.io/badge/article-pdf-blue.svg?style=flat" alt="Read the article"/></a>
[![arXiv](https://img.shields.io/badge/arXiv-2110.11839-b31b1b.svg)](https://arxiv.org/abs/2110.11839)

This repo re-generates [Palumbo et al. (2022)](https://arxiv.org/abs/2110.11839) using the [showyourwork](https://github.com/showyourwork/showyourwork) workflow. This paper was not originally built with showyourwork, but I've retroactively ported it over after publication for the sake of reproducibility (and also as practice for myself using showyourwork).

This paper was written with and presents version 1.0.x of [GRASS](https://github.com/palumbom/GRASS). All other package dependencies are documented in semi-human readable format in Manifest.toml, which the paper scripts will use to instantiate the Julia environment needed to run them.

Note that the Figures 4 through 7 are *probabilistic* and not deterministic, so tiny differenes in the exact data points/errors from the published article may be noticeable.

## Author & Contact
[![Twitter Follow](https://img.shields.io/twitter/follow/michael_palumbo?style=social)](https://twitter.com/michael_palumbo) [![GitHub followers](https://img.shields.io/github/followers/palumbom?label=Follow&style=social)](https://github.com/palumbom)

This repo is maintained by Michael Palumbo. You may may contact him via his email - [palumbo@psu.edu](mailto:palumbo@psu.edu)
