#!/bin/bash
#SBATCH --job-name=bwa_align
#SBATCH --output=logs/bwa_align_%a.log
#SBATCH --array=1-188
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --dependency=afterok:<indexjobid>

source config.sh

# Read-group fields (see data/read-groups.tsv for full sample list):
# ID  → Unique read-group identifier: {SampleID}_{LibraryNumber}_{Flowcell}_{Lane}
#        e.g. CZA04_1_HHKJNCCX2_2 = sample CZA04, library 1, flowcell HHKJNCCX2, lane 2
# SM  → Sample name (individual ID, e.g. CZA04)
# LB  → Library number — used by Picard to identify PCR duplicates across lanes
#        from the same library preparation
# PU  → Platform unit: {Flowcell}_{Lane} — used for batch effect detection
#        e.g. HHKJNCCX2_2 = flowcell HHKJNCCX2, lane 2
# PL  → Sequencing platform (Illumina)

# Parse read-group fields for this array task from deposited TSV
# (data/read-groups.tsv; see repository root README for schema description)
ASSIGN=$(awk -F"\t" -v N=$SLURM_ARRAY_TASK_ID '
  NR==1 {for(i=1;i<=NF;i++) vars[i]=$i; next}
  $1 == N {for(i=1;i<=NF;i++) printf("%s=%s; ", vars[i], $i)}
' $READ_GROUPS_TSV)
eval $ASSIGN

# Align sample to reference genome (BWA v0.7.17, MEM algorithm, default parameters)
# -M: mark shorter split hits as secondary (required for Picard compatibility)
$PROG_BWA mem -M \
  -R "@RG\tID:$ID\tSM:$SM\tLB:$LB\tPU:$PU\tPL:$PL" \
  $INDEXED_GENOME \
  ${SM}.1.fq.gz ${SM}.2.fq.gz \
  > $OUT_SAM/${SM}.sam

# Convert SAM to BAM and sort by coordinate (Samtools v1.17)
$PROG_SAM view -bS $OUT_SAM/${SM}.sam \
  | $PROG_SAM sort -o $OUT_BAM/${SM}_sorted.bam
