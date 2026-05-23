#!/bin/bash
#SBATCH --job-name=prepare_bamlists
#SBATCH --output=logs/prepare_bamlists.log
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:30:00
#SBATCH --dependency=afterok:<indexjobid>

source config.sh

cd $WD

# Prepare full BAM list from sorted BAM directory
ls $BAM_DIR/*.bam > $BAM_LIST
echo "BAM list prepared: $(wc -l < $BAM_LIST) samples found"

# Prepare population-specific BAM lists
# Populations: CZA FLE FPC FPQ FRI GGY ICA IMO ILA ISD IST ITA MCO MGO MMA TZE
# Population names are matched against BAM file paths using grep
# Each population's BAM list is written to a separate file
while IFS= read -r POP; do
  grep "$POP" $BAM_LIST > $WD/${POP}.bamlist
  N=$(wc -l < $WD/${POP}.bamlist)
  echo "Population ${POP}: ${N} samples"
done < $POP_LIST
