#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=2GB
#SBATCH --time=48:00:00
#SBATCH --allocation=ebf11_c
#SBATCH --job-name=P22_fig4
#SBATCH -o /storage/home/mlp95/work/logs/grass/

date
echo "Job id: $SLURM_JOBID"
echo "About to change into $SLURM_SUBMIT_DIR"
cd $SLURM_SUBMIT_DIR
echo "About to start Julia"
julia -p 7 /storage/home/mlp95/work/palubmo22/scripts/fig4_sim.jl
echo "Julia exited"
date
