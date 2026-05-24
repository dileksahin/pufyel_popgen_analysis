#!/bin/bash
#SBATCH --job-name=ngsadmix
#SBATCH --output=logs/ngsadmix_K%a.log
#SBATCH --array=1-14
#SBATCH --cpus-per-task=12
#SBATCH --mem=32G
#SBATCH --time=23:00:00

source config.sh

mkdir -p $OUT_ADMIX $OUT_BESTREPS $OUT_PLOTS

K=$SLURM_ARRAY_TASK_ID

echo "Running NGSadmix for K=$K, $N_RUNS independent runs"

# Run NGSadmix N_RUNS times per K value with random seeds
# Multiple runs per K are required to:
#   1. Assess convergence
#   2. Identify the best run for downstream visualisation
#   3. Provide replicates for Evanno deltaK calculation
#
# Note: each run is submitted as a background process within the same
# SLURM job to avoid excessive job submissions while keeping runs independent
for run in $(seq 1 $N_RUNS); do
  $PROG_NGSADMIX/NGSadmix \
    -likes $BEAGLE \
    -K $K \
    -P $NGSADMIX_THREADS \
    -seed $RANDOM \
    -o $OUT_ADMIX/${INFILE_PREFIX}_admix${K}_run${run} &
done

# Wait for all background runs to complete before SLURM job exits
wait

echo "NGSadmix complete for K=$K"
echo "Log likelihoods:"
for run in $(seq 1 $N_RUNS); do
  LH=$(grep -Po 'like=\K[^ ]+' \
    $OUT_ADMIX/${INFILE_PREFIX}_admix${K}_run${run}.log 2>/dev/null || echo "NA")
  echo "  K=$K run=$run lnL=$LH"
done
