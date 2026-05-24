#!/bin/bash
#SBATCH --job-name=prepare_logfile
#SBATCH --output=logs/prepare_logfile.log
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:30:00
#SBATCH --dependency=afterok:<ngsadmixjobid>

source config.sh

cd $OUT_ADMIX

# Extract log likelihoods and K values from all NGSadmix log files
# Output file format (tab-delimited): K  lnL
# This file is used for best K determination via:
#   1. Clumpak web tool (http://clumpak.tau.ac.il/bestK.html)
#   2. R implementation of Pritchard and Evanno methods (05_bestK.R)
echo -e "K\trun\tlnL" > admix_${INFILE_PREFIX}_runs_LH.txt

for K in $(seq 1 $K_MAX); do
  for run in $(seq 1 $N_RUNS); do
    LOG="${INFILE_PREFIX}_admix${K}_run${run}.log"
    if [[ -f "$LOG" ]]; then
      LH=$(grep -Po 'like=\K[^ ]+' $LOG)
      echo -e "$K\t$run\t$LH" >> admix_${INFILE_PREFIX}_runs_LH.txt
    else
      echo "WARNING: missing log file $LOG"
    fi
  done
done
