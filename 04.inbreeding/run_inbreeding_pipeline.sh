#!/bin/bash

# Inbreeding Coefficient Pipeline
# =============================================================================
# Submits inbreeding estimation steps as dependent SLURM jobs:
#   01_generate_glf.sh	Generate binary GLF file using ANGSD
#   02_run_ngsF.sh	Estimate individual inbreeding coefficients (F)
#
# Usage:
#   bash run_inbreeding_pipeline.sh
#
# Requirements:
#   - Edit config.sh before running
#   - ind.bamlist must be present at $IND_BAMLIST
#   - Sorted BAM files must be present (output of 01.mapping)
#
# Output:
#   - ${OUT_INBREEDING}/ys50_autosome_indF
#     Individual inbreeding coefficients (one value per line)
#     Used as input for 05.admixture and 06.SAF_and_2dSFS
#
# Software:
#   - ANGSD (Korneliussen et al., 2014)
#   - ngsF (Vieira et al., 2013)
# =============================================================================

source config.sh

mkdir -p logs $OUT_GENO $OUT_INBREEDING

# Step 1: Generate binary GLF file using ANGSD
#         All sites must be variable (SNP filters applied)
#         doGlf 3 produces binary format required by ngsF
# -----------------------------------------------------------------------------
GLF_JOB=$(sbatch scripts/01_generate_glf.sh | awk '{print $NF}')
echo "Submitted 01_generate_glf.sh — Job ID: $GLF_JOB"

# Step 2: Estimate individual inbreeding coefficients using ngsF
#         Random starting points used due to low-coverage data
#         Strict convergence threshold (min_epsilon 1e-9) applied
# -----------------------------------------------------------------------------
NGSF_JOB=$(sbatch --dependency=afterok:$GLF_JOB \
  scripts/02_run_ngsF.sh | awk '{print $NF}')
echo "Submitted 02_run_ngsF.sh — Job ID: $NGSF_JOB (depends on $GLF_JOB)"
