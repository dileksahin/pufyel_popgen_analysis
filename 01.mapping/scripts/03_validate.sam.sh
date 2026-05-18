#!/bin/bash
#SBATCH --job-name=validate_sam
#SBATCH --output=logs/validate_sam_%a.log
#SBATCH --array=1-188
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --dependency=afterok:<alignjobid>

source config.sh

# Parse sample name for this array task
ASSIGN=$(awk -F"\t" -v N=$SLURM_ARRAY_TASK_ID '
  NR==1 {for(i=1;i<=NF;i++) vars[i]=$i; next}
  $1 == N {for(i=1;i<=NF;i++) printf("%s=%s; ", vars[i], $i)}
' $READ_GROUPS_TSV)
eval $ASSIGN

# Validate SAM file using GATK Picard Tools v3.0.0
# Java heap explicitly set via config.sh to avoid out-of-memory failures on HPC nodes
java $JAVA_HEAP -jar $PICARD_JAR ValidateSamFile \
  -I $OUT_SAM/${SM}.sam \
  -O $OUT_VALIDATE/${SM}_validate.txt \
  -MODE SUMMARY

# Report validation result for this sample
if grep -q "No errors found" $OUT_VALIDATE/${SM}_validate.txt; then
  echo "Sample ${SM}: validation passed"
else
  echo "Sample ${SM}: validation FAILED — check $OUT_VALIDATE/${SM}_validate.txt"
fi
