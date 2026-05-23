#!/bin/bash
#SBATCH --job-name=genotype_likelihoods
#SBATCH --output=logs/genotype_likelihoods.log
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --dependency=afterok:<prepjobid>

source config.sh

mkdir -p $OUT_GENO

# Calculate minimum individual threshold:
# sites must be present in at least 50% of all individuals
nInd=$(wc -l < $BAM_LIST)
mInd=$((${nInd}/2))

# Calculate genotype likelihoods for all samples using ANGSD
# Output prefix: ys50_autosome (ys=Yelkouan Shearwater, 50=50% missingness threshold)
# Autosomal sites only


$PROG_ANGSD/angsd \
  -bam $BAM_LIST \
  -ref $REF_GENOME \
  -out $OUT_GENO/ys50_autosome \
  -sites $AUTOSOME_SITES \
  -GL $GL \
  -doMajorMinor $DO_MAJOR_MINOR \
  -doMaf $DO_MAF \
  -doGlf $DO_GLF \
  -doCounts $DO_COUNTS
  -minMapQ $MIN_MAPQ \
  -minQ $MIN_Q \
  -minInd $mInd \
  -SNP_pval $SNP_PVAL \
  -minMaf $MIN_MAF \
  -nThreads $NTHREADS
