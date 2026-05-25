#!/bin/bash
#SBATCH --job-name=calculate_2dsfs
#SBATCH --output=logs/2dsfs_%a.log
#SBATCH --array=1-120
#SBATCH --cpus-per-task=40
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --dependency=afterok:<safjobid>

source config.sh

mkdir -p $OUT_2DSFS

# Read population pair for this array task
pair=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $PAIRS_FILE)
pop1=$(echo $pair | cut -d' ' -f1)
pop2=$(echo $pair | cut -d' ' -f2)

if [[ -z "$pop1" || -z "$pop2" ]]; then
  echo "ERROR: could not parse population pair for task $SLURM_ARRAY_TASK_ID"
  exit 1
fi

echo "Calculating 2dSFS for $pop1 vs $pop2"

# Verify SAF index files exist
for pop in $pop1 $pop2; do
  if [[ ! -f "$OUT_SAF/${pop}_autosome.saf.idx" ]]; then
    echo "ERROR: SAF index not found: $OUT_SAF/${pop}_autosome.saf.idx"
    exit 1
  fi
done

# Calculate folded two-dimensional site frequency spectrum (2dSFS)
# -fold 1    use folded spectrum; ancestral allele polarisation not possible
#            as reference genome is used as proxy for ancestral (-anc in SAF step)
# -P 40      parallelise across 40 threads (match --cpus-per-task and OMP_NUM_THREADS)
# Output is used as prior for Fst estimation in 05_calculate_fst.sh

$PROG_REALSFS \
  $OUT_SAF/${pop1}_autosome.saf.idx \
  $OUT_SAF/${pop2}_autosome.saf.idx \
  -fold $FOLD \
  -P $SFS_THREADS \
  > $OUT_2DSFS/${pop1}.${pop2}_autosome_folded.2dsfs
