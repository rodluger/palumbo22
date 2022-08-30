#!/bin/bash
#SBATCH -A ebf11_c
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=2GB
#SBATCH --time=24:00:00
#SBATCH --job-name=P22_fig4
#SBATCH --output=/storage/home/mlp95/work/logs/grass/fig4_sim.%j.out
#SBATCH --error=/storage/home/mlp95/work/logs/grass/fig4_sim.%j.err

date
echo "Job id: $SLURM_JOBID"
echo "About to change into $SLURM_SUBMIT_DIR"
cd $SLURM_SUBMIT_DIR
echo "About to start Julia"
julia /storage/home/mlp95/work/palubmo22/scripts/fig4_sim.jl
echo "Julia exited"
date
