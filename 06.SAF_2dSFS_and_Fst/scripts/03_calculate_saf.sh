#!/bin/bash
#SBATCH --job-name=calculate_saf
#SBATCH --output=logs/saf_%a.log
#SBATCH --array=1-16
#SBATCH --cpus-per-task=40
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --dependency=afterok:<pairsjobid>

source config.sh

mkdir -p $OUT_SAF

# Read population name for this array task
pop=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $POP_LIST)

if [[ -z "$pop" ]]; then
  echo "ERROR: no population found for array task $SLURM_ARRAY_TASK_ID"
  exit 1
fi

echo "Generating SAF for population: $pop"

# Verify BAM list and inbreeding file exist
if [[ ! -f "$OUT_BAMLISTS/${pop}.bamlist" ]]; then
  echo "ERROR: BAM list not found: $OUT_BAMLISTS/${pop}.bamlist"
  exit 1
fi

if [[ ! -f "$$OUT_INBREEDIN/${pop}.indF" ]]; then
  echo "ERROR: inbreeding coefficient file not found: $$OUT_INBREEDIN/${pop}.indF"
  echo "Check output of 04.inbreeding pipeline"
  exit 1
fi

# Calculate site allele frequency (SAF) likelihoods per population

$PROG_ANGSD/angsd \
  -b $OUT_BAMLISTS/${pop}.bamlist \
  -ref $REF_GENOME \
  -anc $REF_GENOME \
  -out $OUT_SAF/${pop}_autosome \
  -GL $GL \
  -doSaf $DO_SAF \
  -doMajorMinor $DO_MAJOR_MINOR \
  -doMaf $DO_MAF \
  -doPost $DO_POST \
  -P $SAF_THREADS \
  -indF $$OUT_INBREEDIN/${pop}.indF
