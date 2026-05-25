#!/bin/bash
#SBATCH --job-name=calculate_fst
#SBATCH --output=logs/fst_%a.log
#SBATCH --array=1-120
#SBATCH --cpus-per-task=40
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --dependency=afterok:<2dsfsjobid>

source config.sh

mkdir -p $OUT_FST

# Read population pair for this array task
pair=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $PAIRS_FILE)
pop1=$(echo $pair | cut -d' ' -f1)
pop2=$(echo $pair | cut -d' ' -f2)

if [[ -z "$pop1" || -z "$pop2" ]]; then
  echo "ERROR: could not parse population pair for task $SLURM_ARRAY_TASK_ID"
  exit 1
fi

echo "Calculating Fst for $pop1 vs $pop2"

# Verify 2dSFS file exists
if [[ ! -f "$OUT_2DSFS/${pop1}.${pop2}_autosome_folded.2dsfs" ]]; then
  echo "ERROR: 2dSFS not found: $OUT_2DSFS/${pop1}.${pop2}_autosome_folded.2dsfs"
  exit 1
fi

# Step 1: Index Fst using 2dSFS as prior
$PROG_REALSFS fst index \
  $OUT_SAF/${pop1}_autosome.saf.idx \
  $OUT_SAF/${pop2}_autosome.saf.idx \
  -sfs $OUT_2DSFS/${pop1}.${pop2}_autosome_folded.2dsfs \
  -fstout $OUT_FST/${pop1}_${pop2} \
  -whichFst $WHICH_FST \
  -P $FST_THREADS

# Step 2: Calculate global weighted and unweighted Fst
$PROG_REALSFS fst stats \
  $OUT_FST/${pop1}_${pop2}.fst.idx \
  > $OUT_FST/${pop1}_${pop2}.fst.txt

echo "Global Fst ($pop1 vs $pop2):"
cat $OUT_FST/${pop1}_${pop2}.fst.txt

# Step 3: Bootstrap Fst in sliding windows for confidence intervals

$PROG_REALSFS fst stats2 \
  $OUT_FST/${pop1}_${pop2}.fst.idx \
  -win $WINDOW \
  -step $STEP \
  -bootstrap $BOOTSTRAP \
  > $OUT_FST/${pop1}_${pop2}.bootstrap

