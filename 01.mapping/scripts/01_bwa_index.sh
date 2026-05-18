#!/bin/bash
#SBATCH --job-name=bwa_index
#SBATCH --output=logs/bwa_index.log
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00

source config.sh
$PROG_BWA/bwa index -p pufmar_genome $REF_GENOME/genome.fa > $INDEXED_GENOME/bwa_index.oe
$PROG_SAM/samtools faidx $INDEXED_GENOME/genome.fa
