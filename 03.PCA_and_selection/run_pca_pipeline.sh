git add 02
git commit -m "Add genotype likelihood pipeline with data"
git push origin main


#!/bin/bash

# PCA and Selection Pipeline
# =============================================================================
# Submits all PCA steps as dependent SLURM jobs in the correct order:
#   01_run_pcangsd.sh		Estimate covariance matrix (PCAngsd)
#   02_prepare_cluster_file.sh	Prepare population cluster file for plotting
#   03_plot_pca.R		Plot PCA and scree plot in R
#
# Usage:
#   bash run_pca_pipeline.sh
#
# Requirements:
#   - Edit config.sh before running
#   - Beagle file must be present (output of 02.genotype_likelihoods)
#   - data/sample.list must be present (one sample ID per line)
#   - R packages: ggplot2, ggpubr
#
# Software:
#   - PCangsd V 1.10 (Meisner and Albrechtsen, 2018) 
#   - R 4.x with ggplot2, ggpubr
# =============================================================================

source config.sh

mkdir -p logs $OUT_PCA $OUT_PLOTS

# Export config variables for use in R script
export WD COV_MATRIX POP_CLST OUT_PLOTS N_IND

# -----------------------------------------------------------------------------
# Step 1: Estimate covariance matrix using PCAngsd
# -----------------------------------------------------------------------------
PCANGSD_JOB=$(sbatch scripts/01_run_pcangsd.sh | awk '{print $NF}')
echo "Submitted 01_run_pcangsd.sh — Job ID: $PCANGSD_JOB"

# -----------------------------------------------------------------------------
# Step 2: Prepare population cluster file for R plotting
# -----------------------------------------------------------------------------
CLUSTER_JOB=$(sbatch --dependency=afterok:$PCANGSD_JOB \
  scripts/02_prepare_cluster_file.sh | awk '{print $NF}')
echo "Submitted 02_prepare_cluster_file.sh — Job ID: $CLUSTER_JOB (depends on $PCANGSD_JOB)"

# -----------------------------------------------------------------------------
# Step 3: Plot PCA results in R
#         Produces scree_plot.png and PCA_combined.png (PC1v2 and PC2v3)
# -----------------------------------------------------------------------------
PLOT_JOB=$(sbatch --dependency=afterok:$CLUSTER_JOB \
  --job-name=plot_pca \
  --output=logs/plot_pca.log \
  --cpus-per-task=2 \
  --mem=16G \
  --time=01:00:00 \
  --wrap="Rscript scripts/03_plot_pca.R" | awk '{print $NF}')
echo "Submitted 03_plot_pca.R — Job ID: $PLOT_JOB (depends on $CLUSTER_JOB)"
