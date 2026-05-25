#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH --output=logs/fastqc.log
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --dependency=afterok:<demuxjobid>

source config.sh

mkdir -p $OUT_QC

# Verify demultiplexed files exist
N_FASTQ=$(ls $OUT_DEMUX/*.fastq.gz 2>/dev/null | wc -l)
if [[ $N_FASTQ -eq 0 ]]; then
  echo "ERROR: no FASTQ files found in $OUT_DEMUX"
  echo "Check that 01_demultiplex.sh completed successfully"
  exit 1
fi

echo "Running FastQC on $N_FASTQ FASTQ files"
echo "Output directory: $OUT_QC"

# Assess sequence quality of all demultiplexed samples using FastQC v0.12.0

find $OUT_DEMUX -name "*.fastq.gz" | xargs $PROG_FASTQC \
  -o $OUT_QC \
  -t $FASTQC_THREADS
