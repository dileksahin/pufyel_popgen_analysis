#!/bin/bash
#SBATCH --job-name=prepare_pairs
#SBATCH --output=logs/prepare_pairs.log
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:15:00
#SBATCH --dependency=afterok:<bamlistsjobid>

source config.sh

mkdir -p $INFO

# Generate all unique population pairs from pop.list
# Output format: one pair per line, space-delimited (e.g. "CZA FLE")
# Used as input for 04_calculate_2dsfs.sh and 05_calculate_fst.sh array jobs

: > $PAIRS_FILE

pops=()
while IFS= read -r pop; do
  pops+=("$pop")
done < $POP_LIST

n=${#pops[@]}
n_pairs=$(( n * (n - 1) / 2 ))

for ((x=0; x<n; x++)); do
  for ((y=x+1; y<n; y++)); do
    echo "${pops[$x]} ${pops[$y]}" >> $PAIRS_FILE
  done
done
