#!/bin/bash
#SBATCH --job-name=ngsF
#SBATCH --output=logs/ngsF.log
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --dependency=afterok:<glfjobid>

source config.sh

# Count number of variable sites from GLF step mafs file
# Subtract 1 to exclude the header line
# Note: N_SITES is derived from the GLF-specific mafs file (ys50_autosome_FIS)
# not from the main genotype likelihoods mafs file, as SNP filters may differ
N_SITES=$(( $(zcat ${GLF_PREFIX}.mafs.gz | wc -l) - 1 ))
echo "Number of variable sites for ngsF: $N_SITES"
echo "Number of individuals: $N_IND"

# Run ngsF to estimate individual inbreeding coefficients (F)
# Output will be used in:
#   - 05.admixture  (as prior for NGSadmix)
#   - 06.SAF_and_2dSFS (as individual inbreeding coefficients)
#
# Key parameter justifications:
# --init_values r    random starting points required for low-coverage data;
#                    initial estimates are unreliable at low coverage so the
#                    approximated algorithm is skipped entirely
# --min_epsilon 1e-9 strict convergence threshold to compensate for
#                    unreliable starting estimates; range is 1e-6 to 1e-9
# --n_threads 16     parallelise across 16 threads (match --cpus-per-task)

$PROG_NGSF/ngsF \
  --glf ${GLF_PREFIX}.glf \
  --n_ind $N_IND \
  --n_sites $N_SITES \
  --init_values $INIT_VALUES \
  --min_epsilon $MIN_EPSILON \
  --n_threads $NGSF_THREADS \
  --out $NGSF_OUT

# Summarise inbreeding coefficients across individuals
echo ""
echo "Inbreeding coefficient summary:"
awk 'BEGIN{min=1;max=0;sum=0;n=0}
     {n++; sum+=$1;
      if($1<min) min=$1;
      if($1>max) max=$1}
     END{printf "  N=%d  mean=%.4f  min=%.4f  max=%.4f\n", n, sum/n, min, max}' \
  $NGSF_OUT

echo "ngsF complete: $NGSF_OUT"
