#!/bin/bash

# Genotype Likelihoods Pipeline
# Submits all genotype likelihood steps as dependent SLURM jobs:
#   01_index_sites.sh		Index autosomal sites file for ANGSD
#   02_prepare_bamlists.sh	Build full and population-specific BAM lists
#   03_genotype_likelihoods.sh	Calculate genotype likelihoods using ANGSD
#
# Usage:
#   bash run_genotype_likelihoods_pipeline.sh
#
# Requirements:
#   - Edit config.sh before running
#   - Sorted BAM files must be present in $BAM_DIR (output of 01.mapping)
#   - data/pop.list must be present
#   - data/autosome_sites.txt must be present
#
# Software:
#   - ANGSD V 0.940(Korneliussen et al., 2014)

source config.sh

mkdir -p logs

# Step 1: Index autosomal sites file
# -----------------------------------------------------------------------------
INDEX_JOB=$(sbatch scripts/01_index_sites.sh | awk '{print $NF}')

# Step 2: Prepare full and population-specific BAM lists
# -----------------------------------------------------------------------------
PREP_JOB=$(sbatch --dependency=afterok:$INDEX_JOB \
  scripts/02_prepare_bamlists.sh | awk '{print $NF}')

# Step 3: Calculate genotype likelihoods for all 188 samples
#         Sites present in <50% individuals excluded (-minInd threshold)
#         Additional filters: minMapQ 10, minQ 20, SNP_pval 1e-12, minMaf 0.05
# -----------------------------------------------------------------------------
GENO_JOB=$(sbatch --dependency=afterok:$PREP_JOB \
  scripts/03_genotype_likelihoods.sh | awk '{print $NF}')
