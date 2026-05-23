#!/bin/bash
#SBATCH --job-name=index_sites
#SBATCH --output=logs/index_sites.log
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=01:00:00

source config.sh

# Index autosomal sites file for ANGSD
# Sex chromosomes are excluded from all downstream analyses;
# they showed strong clustering in initial PCA checks
# Note: sites file must have more than one column for ANGSD indexing
$PROG_ANGSD/angsd sites index $AUTOSOME_SITES
