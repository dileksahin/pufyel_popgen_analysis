#!/bin/bash
# =============================================================================
# SAF, 2dSFS and Fst Pipeline
# =============================================================================
# Submits all steps as dependent SLURM jobs:
#   01_prepare_bamlists.sh	Population-specific BAM lists
#   02_prepare_pop_pairs.sh	All unique population pairs file
#   03_calculate_saf.sh		SAF likelihoods per population (array: 1-16)
#   04_calculate_2dsfs.sh	2dSFS per population pair (array: 1-120)
#   05_calculate_fst.sh		Global Fst + bootstrap CI per pair (array: 1-120)
#   06_plot_fst.R		Heatmap and forest plot
#
# Usage:
#   bash run_saf_2dsfs_pipeline.sh
#
# Requirements:
#   - Edit config.sh before running
#   - Sorted BAM files present (output of 01.mapping)
#   - Inbreeding coefficients present (output of 04.inbreeding)
#   - PIPELINE_ROOT set so POP_LIST resolves to
#     02.genotype_likelihoods/data/pop.list
#
# Array sizes:
#   SAF:    1 task per population  (n=16 --array=1-16)
#   2dSFS:  1 task per pair        (n=120 --array=1-120 for 16 populations)
#   Fst:    1 task per pair        (n=120 --array=1-120)
#   Update these if population count changes.
#
# Software:
#   - ANGSD (Korneliussen et al., 2014)
#   - realSFS — part of ANGSD misc utilities
#   - R 4.x with ggplot2, dplyr
# =============================================================================

source config.sh

mkdir -p logs $OUT_BAMLISTS $OUT_SAF $OUT_2DSFS $OUT_FST $OUT_PLOTS

# Export paths for R script
export WD OUT_FST OUT_PLOTS POP_LIST

# -----------------------------------------------------------------------------
# Step 1: Prepare population-specific BAM lists from shared pop.list
# -----------------------------------------------------------------------------
BAMLIST_JOB=$(sbatch scripts/01_prepare_bamlists.sh | awk '{print $NF}')

# -----------------------------------------------------------------------------
# Step 2: Generate all unique population pairs file
#         Output: $INFO/pop_pairs.txt — used by array jobs in steps 4 and 5
# -----------------------------------------------------------------------------
PAIRS_JOB=$(sbatch --dependency=afterok:$BAMLIST_JOB \
  scripts/02_prepare_pop_pairs.sh | awk '{print $NF}')

# -----------------------------------------------------------------------------
# Step 3: Calculate SAF likelihoods per population
#         Array: one task per population (16 populations)
#         Incorporates individual inbreeding coefficients via -indF
# -----------------------------------------------------------------------------
SAF_JOB=$(sbatch --dependency=afterok:$PAIRS_JOB \
  scripts/03_calculate_saf.sh | awk '{print $NF}')

# -----------------------------------------------------------------------------
# Step 4: Calculate folded 2dSFS for all population pairs
#         Array: one task per pair (120 pairs for 16 populations)
# -----------------------------------------------------------------------------
SFS_JOB=$(sbatch --dependency=afterok:$SAF_JOB \
  scripts/04_calculate_2dsfs.sh | awk '{print $NF}')

# -----------------------------------------------------------------------------
# Step 5: Calculate global Fst and bootstrap CI for all population pairs
#         Array: one task per pair (120 pairs)
# -----------------------------------------------------------------------------
FST_JOB=$(sbatch --dependency=afterok:$SFS_JOB \
  scripts/05_calculate_fst.sh | awk '{print $NF}')

# -----------------------------------------------------------------------------
# Step 6: Plot Fst heatmap and forest plot with 95% CI
# -----------------------------------------------------------------------------
PLOT_JOB=$(sbatch --dependency=afterok:$FST_JOB \
  --job-name=plot_fst \
  --output=logs/plot_fst.log \
  --cpus-per-task=2 \
  --mem=16G \
  --time=01:00:00 \
  --wrap="Rscript scripts/06_plot_fst.R" | awk '{print $NF}')
