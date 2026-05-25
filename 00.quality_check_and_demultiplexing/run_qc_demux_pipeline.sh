#!/bin/bash

# Quality Check and Demultiplexing Pipeline
# =============================================================================
# Submits all QC and demultiplexing steps as dependent SLURM jobs:
#   01_demultiplex.sh  Demultiplex raw reads using Stacks process_radtags
#   02_fastqc.sh       Assess read quality using FastQC
#
# Usage:
#   bash run_qc_demux_pipeline.sh
#
# Requirements:
#   - Edit config.sh before running
#   - Raw sequencing files present in $RAW_FILES
#   - data/barcodes.txt present (see README.md for format)
#
# This is the first step in the pipeline. Output FASTQ files feed into:
#   01.mapping — read alignment to reference genome
#
# Software:
#   - Stacks v2.58 process_radtags (Catchen et al., 2013)
#   - FastQC v0.12.0 (Andrews, 2010)
# =============================================================================

source config.sh

mkdir -p logs $OUT_DEMUX $OUT_QC $OUT_MULTIQC

# -----------------------------------------------------------------------------
# Step 1: Demultiplex raw RADseq reads
#         Inline+index barcodes, pstI+mseI dual digest
#         Rescues barcodes (-r), removes reads with Ns (-c),
#         quality filters with sliding window (-q)
# -----------------------------------------------------------------------------
DEMUX_JOB=$(sbatch scripts/01_demultiplex.sh | awk '{print $NF}')
echo "Submitted 01_demultiplex.sh — Job ID: $DEMUX_JOB"

# -----------------------------------------------------------------------------
# Step 2: Assess quality of all demultiplexed samples using FastQC
# -----------------------------------------------------------------------------
FASTQC_JOB=$(sbatch --dependency=afterok:$DEMUX_JOB \
  scripts/02_fastqc.sh | awk '{print $NF}')
echo "Submitted 02_fastqc.sh — Job ID: $FASTQC_JOB (depends on $DEMUX_JOB)"
