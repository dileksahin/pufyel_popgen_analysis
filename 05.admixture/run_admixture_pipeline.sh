#!/bin/bash

# Admixture Pipeline
# =============================================================================
# Submits all admixture steps as dependent SLURM jobs:
#   01_run_ngsadmix.sh      Run NGSadmix K=1..14, 10 runs each (array)
#   02_prepare_logfile.sh   Extract lnL values and prepare likelihood file
#   03_run_evaladmix.sh     Evaluate model fit per K (array)
#   04_find_bestreps.sh     Identify best replicate per K by lnL (array)
#   05_bestK.R              Determine best K (Pritchard and Evanno methods)
#   06_plot_admixture.R     Plot admixture proportions using pophelper
#
# Usage:
#   bash run_admixture_pipeline.sh
#
# Requirements:
#   - Edit config.sh before running
#   - Beagle file must be present (output of 02.genotype_likelihoods)
#   - Inbreeding coefficients must be present (output of 04.inbreeding)
#   - data/admix_sample.list.txt and data/admixture_groups.list.txt
#     must be present (see README.md)
#
# Software:
#   - NGSadmix (Skotte et al., 2013)
#   - evalAdmix (Garcia-Erill and Albrechtsen, 2020)
#   - R 4.x with pophelper, ggplot2, dplyr, ggpubr, gridExtra
# =============================================================================

source config.sh

mkdir -p logs $OUT_ADMIX $OUT_BESTREPS $OUT_PLOTS

# Export config variables for R scripts
export WD OUT_ADMIX OUT_BESTREPS OUT_PLOTS INFO
export SAMPLE_LIST GROUPS_LIST BEST_RUN_INDICES
export K_MAX N_RUNS INFILE_PREFIX

# -----------------------------------------------------------------------------
# Step 1: Run NGSadmix for K=1..14, 10 independent runs each
#         Array job: one task per K value
# -----------------------------------------------------------------------------
NGSADMIX_JOB=$(sbatch scripts/01_run_ngsadmix.sh | awk '{print $NF}')

# -----------------------------------------------------------------------------
# Step 2: Extract log likelihoods from all runs and prepare likelihood file
#         Also prepares sample list from BAM file paths
# -----------------------------------------------------------------------------
LOGFILE_JOB=$(sbatch --dependency=afterok:$NGSADMIX_JOB \
  scripts/02_prepare_logfile.sh | awk '{print $NF}')

# -----------------------------------------------------------------------------
# Step 3: Evaluate admixture model fit using evalAdmix (array job)
#         Residual correlations used to confirm best replicate per K
# -----------------------------------------------------------------------------
EVALADMIX_JOB=$(sbatch --dependency=afterok:$LOGFILE_JOB \
  scripts/03_run_evaladmix.sh | awk '{print $NF}')

# -----------------------------------------------------------------------------
# Step 4: Identify best replicate per K based on log likelihood (array job)
#         Copies best qopt file to bestReps/ for visualisation
# -----------------------------------------------------------------------------
BESTREPS_JOB=$(sbatch --dependency=afterok:$EVALADMIX_JOB \
  scripts/04_find_bestreps.sh | awk '{print $NF}')

# -----------------------------------------------------------------------------
# Step 5: Determine best K using Pritchard and Evanno methods in R
# -----------------------------------------------------------------------------
BESTK_JOB=$(sbatch --dependency=afterok:$BESTREPS_JOB \
  --job-name=bestK \
  --output=logs/bestK.log \
  --cpus-per-task=2 \
  --mem=8G \
  --time=00:30:00 \
  --wrap="Rscript scripts/05_bestK.R" | awk '{print $NF}')

# -----------------------------------------------------------------------------
# Step 6: Plot admixture proportions using pophelper
#         Note: update BEST_RUN_INDICES in config.sh after reviewing
#         evalAdmix output before running this step
# -----------------------------------------------------------------------------
PLOT_JOB=$(sbatch --dependency=afterok:$BESTK_JOB \
  --job-name=plot_admixture \
  --output=logs/plot_admixture.log \
  --cpus-per-task=2 \
  --mem=16G \
  --time=01:00:00 \
  --wrap="Rscript scripts/06_plot_admixture.R" | awk '{print $NF}')
