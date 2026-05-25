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

# =============================================================================
# Split ngsF output into population-specific inbreeding coefficient files
# =============================================================================
# ngsF outputs a single file with one inbreeding coefficient per line,
# in the same order as individuals in $IND_BAMLIST.
# Population labels are extracted from the shared sample.list
# (03.PCA_and_selection/data/sample.list) which contains one sample ID per line.
# Population code is derived from characters 1-3 of each sample ID
# (e.g. CZA04 -> CZA).
#
# Output: one ${pop}.indF file per population in $INDF_DIR
#         each file contains inbreeding coefficients for individuals
#         belonging to that population, in the original sample order
# =============================================================================

SAMPLE_LIST="${PIPELINE_ROOT}/03.PCA_and_selection/data/sample.list"

if [[ ! -f "$SAMPLE_LIST" ]]; then
  echo "ERROR: sample.list not found at $SAMPLE_LIST"
  echo "Check PIPELINE_ROOT in config.sh"
  exit 1
fi

if [[ ! -f "$NGSF_OUT" ]]; then
  echo "ERROR: ngsF output not found at $NGSF_OUT"
  echo "Check that ngsF completed successfully"
  exit 1
fi

# Verify individual counts match between sample.list and ngsF output
N_SAMPLES=$(wc -l < $SAMPLE_LIST)
N_INDF=$(wc -l < $NGSF_OUT)

if [[ $N_SAMPLES -ne $N_INDF ]]; then
  echo "ERROR: sample count mismatch"
  echo "  sample.list: $N_SAMPLES individuals"
  echo "  ngsF output: $N_INDF coefficients"
  echo "  These must match — check sample.list and IND_BAMLIST are consistent"
  exit 1
fi

echo ""
echo "Splitting ngsF output into population-specific inbreeding files"
echo "Individuals: $N_SAMPLES | Populations: $(cut -c1-3 $SAMPLE_LIST | sort -u | tr '\n' ' ')"

mkdir -p $INDF_DIR

# Clear any existing population indF files to avoid appending to stale output
while IFS= read -r pop; do
  > $INDF_DIR/${pop}.indF
done < "${PIPELINE_ROOT}/02.genotype_likelihoods/data/pop.list"

# Paste sample IDs alongside inbreeding coefficients, then split by population
# awk extracts population code from characters 1-3 of the sample ID
paste $SAMPLE_LIST $NGSF_OUT | \
  awk '{
    pop = substr($1, 1, 3)
    print $2 > ("'"$OUT_INBREEDING"'/" pop ".indF")
  }'

# Report number of individuals written per population file
echo ""
while IFS= read -r pop; do
  if [[ ! -f "$OUT_INBREEDING/${pop}.indF" ]]; then
    echo "  WARNING: no inbreeding coefficients written for $pop"
  else
    N=$(wc -l < $OUT_INBREEDING/${pop}.indF)
    echo "  ${pop}.indF: $N individuals"
  fi
done < "${PIPELINE_ROOT}/02.genotype_likelihoods/data/pop.list"

echo ""
echo "Population inbreeding files written to: $OUT_INBREEDING"
