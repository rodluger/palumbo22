#!/bin/bash
#SBATCH -A ebf11_c
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=48:00:00
#SBATCH --job-name=P22_fig6
#SBATCH --chdir=/storage/home/mlp95/work/palumbo22
#SBATCH --output=/storage/home/mlp95/work/logs/fig6_sim.%j.out

echo "About to start: $SLURM_JOB_NAME"
date
echo "Job id: $SLURM_JOBID"
echo "About to change into $SLURM_SUBMIT_DIR"
cd $SLURM_SUBMIT_DIR
echo "About to start Julia"
julia -e "using Pkg; Pkg.activate(\".\"); Pkg.precompile()"
julia -p 2 src/scripts/fig6_sim.jl
echo "Julia exited"
date
