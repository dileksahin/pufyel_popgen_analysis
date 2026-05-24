#!/bin/bash
#SBATCH --job-name=evaladmix
#SBATCH --output=logs/evaladmix_K%a.log
#SBATCH --array=1-14
#SBATCH --cpus-per-task=20
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --dependency=afterok:<logfilejobid>

source config.sh

K=$SLURM_ARRAY_TASK_ID

echo "Running evalAdmix for K=$K, $BOOTSTRAP bootstrap replicates"

# Evaluate admixture model fit for each run at this K using evalAdmix
# evalAdmix assesses how well the admixture model fits the data by
# calculating residual correlations between individuals
# The run with residuals closest to zero is the best fit for that K
# Results are used in 04_find_bestreps.sh to select the best run per K

for run in $(seq 1 $BOOTSTRAP); do
  echo "  K=$K run=$run"
  $PROG_EVALADMIX/evalAdmix \
    -beagle $BEAGLE \
    -fname $OUT_ADMIX/${INFILE_PREFIX}_admix${K}_run${run}.fopt.gz \
    -qname $OUT_ADMIX/${INFILE_PREFIX}_admix${K}_run${run}.qopt \
    -o $OUT_ADMIX/${INFILE_PREFIX}_admix${K}_run${run} \
    -P $EVALADMIX_THREADS
done
