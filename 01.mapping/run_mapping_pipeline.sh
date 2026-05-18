#!/bin/bash
# =============================================================================
# Mapping Pipeline — Balearic Shearwater (Puffinus mauritanicus)
# =============================================================================
# Submits all mapping steps as dependent SLURM jobs in the correct order:
#   01_bwa_index.sh        Build BWA index (single job)
#   02_bwa_align.sh        Align samples to reference genome (array: 1-188)
#   03_validate_sam.sh     Validate SAM files using Picard (array: 1-188)
#   04_flagstat.sh         Calculate alignment statistics (array: 1-188)
#
# Usage:
#   bash run_mapping_pipeline.sh
#
# Requirements:
#   - Edit config.sh before running to set paths for your system
#   - data/read-groups.tsv must be present (see README.md for schema)
#
# Software versions:
#   - BWA v0.7.17 (Li and Durbin, 2009)
#   - Samtools v1.17 (Danecek et al., 2021)
#   - GATK Picard Tools v3.0.0 (Broad Institute, 2023)
#   - fastq_pair v1.0 (Edwards and Edwards, 2019)
# =============================================================================

source config.sh

# Create log directory 
mkdir -p logs

# Step 1: Build BWA index (single job, must complete before alignment starts)

INDEX_JOB=$(sbatch 01_bwa_index.sh | awk '{print $NF}')
echo "Submitted 01_bwa_index.sh — Job ID: $INDEX_JOB"

# Step 2: Align all 188 samples to reference genome (array job)
#         Starts only after index job completes successfully

ALIGN_JOB=$(sbatch --dependency=afterok:$INDEX_JOB \
  scripts/02_bwa_align.sh | awk '{print $NF}')
echo "Submitted 02_bwa_align.sh — Job ID: $ALIGN_JOB (depends on $INDEX_JOB)"

# Step 3: Validate SAM files using Picard ValidateSamFile (array job)
#         Starts only after all alignment jobs complete successfully

VALIDATE_JOB=$(sbatch --dependency=afterok:$ALIGN_JOB \
  scripts/03_validate_sam.sh | awk '{print $NF}')
echo "Submitted 03_validate_sam.sh — Job ID: $VALIDATE_JOB (depends on $ALIGN_JOB)"

# Step 4: Calculate alignment statistics and flag low-quality samples (array job)
#         Starts only after all SAM files are sorted and converted to BAM
#         Filters: <90% mapping rate or <100,000 aligned reads

FLAGSTAT_JOB=$(sbatch --dependency=afterok:$VALIDATE_JOB \
  scripts/04_flagstat.sh | awk '{print $NF}')
echo "Submitted 04_flagstat.sh — Job ID: $FLAGSTAT_JOB (depends on $VALIDATE_JOB)"
