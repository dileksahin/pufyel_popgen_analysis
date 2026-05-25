#!/bin/bash
#SBATCH --job-name=prepare_bamlists
#SBATCH --output=logs/prepare_bamlists.log
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:30:00

source config.sh

mkdir -p $OUT_BAMLISTS

# Prepare population-specific BAM lists by filtering the full 188-sample
# BAM list from 01.mapping by population code
# Output: one ${pop}.bamlist per population in $OUT_BAMLISTS
#         each file contains paths to BAM files whose filename contains
#         the population code (e.g. CZA04_sorted.bam -> CZA.bamlist)

if [[ ! -f "$BAM_LIST" ]]; then
  echo "ERROR: full BAM list not found at $BAM_LIST"
  echo "Check BAM_LIST in config.sh — should point to 01.mapping output"
  exit 1
fi

if [[ ! -f "$POP_LIST" ]]; then
  echo "ERROR: pop.list not found at $POP_LIST"
  echo "Check PIPELINE_ROOT in config.sh"
  exit 1
fi

echo "Filtering BAM list: $BAM_LIST"
echo "Total individuals: $(wc -l < $BAM_LIST)"
echo ""

total_assigned=0

while IFS= read -r pop; do
  grep "$pop" $BAM_LIST > $OUT_BAMLISTS/${pop}.bamlist
  N=$(wc -l < $OUT_BAMLISTS/${pop}.bamlist)
  echo "  ${pop}: $N individuals"
  if [[ $N -eq 0 ]]; then
    echo "  WARNING: no BAM paths matched population code $pop"
    echo "  Check that BAM filenames contain the population code (e.g. ${pop}04_sorted.bam)"
  fi
  total_assigned=$((total_assigned + N))
done < $POP_LIST

echo ""
echo "Total individuals assigned across all populations: $total_assigned"
if [[ $total_assigned -ne $(wc -l < $BAM_LIST) ]]; then
  echo "WARNING: assigned count ($total_assigned) does not match"
  echo "         total BAM list count ($(wc -l < $BAM_LIST))"
  echo "         Some individuals may be unassigned or matched multiple populations"
fi

echo "Population BAM lists written to: $OUT_BAMLISTS"
