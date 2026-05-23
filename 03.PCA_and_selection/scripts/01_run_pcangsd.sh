#!/bin/bash
#SBATCH --job-name=pcangsd
#SBATCH --output=logs/pcangsd.log
#SBATCH --cpus-per-task=28
#SBATCH --mem=64G
#SBATCH --time=12:00:00

source config.sh

mkdir -p $OUT_PCA

# Estimate covariance matrix using PCAngsd
# Input: beagle genotype likelihood file from 02.genotype_likelihoods
#
# Key parameter justifications:
# -n_eig 7       number of significant eigenvalues to use in model;
#                set to 7 based on number of countries sampled
# -threads 28    parallelise across 28 threads (match --cpus-per-task)
# --snp_weights  estimate per-SNP weights for the covariance matrix
# -pcadapt       perform pcadapt-based selection scan
# -selection_e 7 number of eigenvectors used in selection scan;
#                matches -n_eig to test all significant axes for selection

$PROG_PCANGSD/pcangsd \
  -b $BEAGLE \
  -o $OUT_PCA/ys50_autosome \
  -n_eig $N_EIG \
  -threads $THREADS \
  --snp_weights \
  -pcadapt \
  -selection_e $SELECTION_E
