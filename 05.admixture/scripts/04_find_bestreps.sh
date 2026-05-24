#!/bin/bash
#SBATCH --job-name=find_bestreps
#SBATCH --output=logs/find_bestreps.log
#SBATCH --array=1-14
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:30:00
#SBATCH --dependency=afterok:<evaladmixjobid>

source config.sh

K=$SLURM_ARRAY_TASK_ID

mkdir -p $OUT_BESTREPS

# Identify the best replicate for each K based on highest log likelihood
# from the final line of each NGSadmix log file
# Method: sort runs by lnL descending, take the top run
# Reference: adapted from https://github.com/hmoral/SPF/blob/main/popgen/3.NGSadmix.v2.sh
#
# Note: lnL-based best rep selection is a preliminary filter.
# Final best rep selection should be confirmed using evalAdmix
# residual correlation output from 03_run_evaladmix.sh

bestrep=$(for rep in $(seq 1 $N_RUNS); do
  LOG="$OUT_ADMIX/${INFILE_PREFIX}_admix${K}_run${rep}.log"
  if [[ -f "$LOG" ]]; then
    LH=$(tail -n 1 $LOG | cut -f2 -d= | cut -f1 -d" ")
    echo "$rep $LH"
  fi
done | sort -k2,2nr | head -1 | cut -f1 -d" ")

if [[ -z "$bestrep" ]]; then
  echo "ERROR: could not determine best replicate for K=$K"
  exit 1
fi

cp $OUT_ADMIX/${INFILE_PREFIX}_admix${K}_run${bestrep}.qopt \
   $OUT_BESTREPS/${INFILE_PREFIX}_admix${K}.run${bestrep}.bestrep.qopt
