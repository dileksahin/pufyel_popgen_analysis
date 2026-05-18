#!/bin/bash
#SBATCH --job-name=flagstat
#SBATCH --output=logs/flagstat_%a.log
#SBATCH --array=1-188
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --dependency=afterok:<sortjobid>

source config.sh

# Parse sample name for this array task
ASSIGN=$(awk -F"\t" -v N=$SLURM_ARRAY_TASK_ID '
  NR==1 {for(i=1;i<=NF;i++) vars[i]=$i; next}
  $1 == N {for(i=1;i<=NF;i++) printf("%s=%s; ", vars[i], $i)}
' $READ_GROUPS_TSV)
eval $ASSIGN

# Calculate alignment statistics per sample (Samtools v1.17 flagstat)
# Output used to filter low-quality samples:
#   - exclude samples with <90% of reads aligned
#   - exclude samples with <100,000 aligned reads
# This filtering step resulted in 188 samples retained for downstream analyses
$PROG_SAM flagstat \
  $OUT_BAM/${SM}_sorted.bam \
  > $OUT_ALI_STATS/${SM}_flagstat.txt

# Report mapping rate for this sample to SLURM log
TOTAL=$(grep "in total" $OUT_ALI_STATS/${SM}_flagstat.txt | awk '{print $1}')
MAPPED=$(grep "mapped (" $OUT_ALI_STATS/${SM}_flagstat.txt | awk '{print $1}')
PCT=$(awk "BEGIN {printf \"%.1f\", ($MAPPED/$TOTAL)*100}")

echo "Sample ${SM}: ${MAPPED}/${TOTAL} reads mapped (${PCT}%)"

if (( $(echo "$PCT < 90" | bc -l) )); then
  echo "WARNING: Sample ${SM} is below 90% mapping threshold"
fi
if (( MAPPED < 100000 )); then
  echo "WARNING: Sample ${SM} is below 100,000 aligned reads threshold"
fi
