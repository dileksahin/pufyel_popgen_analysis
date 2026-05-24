#!/bin/bash
#SBATCH --job-name=generate_glf
#SBATCH --output=logs/generate_glf.log
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=24:00:00

source config.sh

mkdir -p $OUT_GENO $OUT_INBREEDING

# Calculate minimum individual threshold:
# sites must be present in at least 50% of individuals
nInd=$(wc -l < $IND_BAMLIST)
mInd=$((${nInd}/2))

# Generate binary GLF file using ANGSD for ngsF input
# ngsF requires:
#   - doGlf 3: binary format (3 * n_ind * n_sites doubles, uncompressed)
#   - all sites must be variable (SNP_pval and minMaf filters applied)
#   - no missing data format is compatible with ngsF

$PROG_ANGSD/angsd \
  -bam $BAM_LIST \
  -ref $REF_GENOME \
  -out $GLF_PREFIX \
  -GL $GL \
  -doGlf $DO_GLF \
  -doMajorMinor $DO_MAJOR_MINOR \
  -doMaf $DO_MAF \
  -SNP_pval $SNP_PVAL \
  -minMaf $MIN_MAF \
  -minMapQ $MIN_MAPQ \
  -minQ $MIN_Q \
  -minInd $mInd \
  -nThreads $NTHREADS
