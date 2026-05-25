#!/bin/bash
#SBATCH --job-name=demultiplex
#SBATCH --output=logs/demultiplex_%a.log
#SBATCH --array=1-3
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=24:00:00

source config.sh

mkdir -p $OUT_DEMUX

# Map array task ID to pool-specific raw file and barcode file
# Each pool was sequenced independently and demultiplexed separately
# Pool 1, 2, and 3 correspond to three sequencing runs with distinct barcode sets
case $SLURM_ARRAY_TASK_ID in
  1) RAW_POOL=$RAW_POOL1
     BARCODE_POOL=$BARCODES_POOL1
     POOL_NAME="pool1" ;;
  2) RAW_POOL=$RAW_POOL2
     BARCODE_POOL=$BARCODES_POOL2
     POOL_NAME="pool2" ;;
  3) RAW_POOL=$RAW_POOL3
     BARCODE_POOL=$BARCODES_POOL3
     POOL_NAME="pool3" ;;
  *)
    echo "ERROR: unexpected array task ID $SLURM_ARRAY_TASK_ID"
    exit 1 ;;
esac

OUT_POOL="$OUT_DEMUX/$POOL_NAME"
mkdir -p $OUT_POOL

# Verify input files exist
if [[ ! -d "$RAW_POOL" ]]; then
  echo "ERROR: raw files directory not found: $RAW_POOL"
  exit 1
fi

if [[ ! -f "$BARCODE_POOL" ]]; then
  echo "ERROR: barcode file not found: $BARCODE_POOL"
  exit 1
fi

echo "============================================="
echo "Processing $POOL_NAME"
echo "  Raw files:    $RAW_POOL"
echo "  Barcodes:     $BARCODE_POOL"
echo "  Output:       $OUT_POOL"
echo "============================================="

# Demultiplex per-pool raw reads using Stacks v2.58 process_radtags

$PROG_STACKS/process_radtags \
  -p $RAW_POOL \
  -b $BARCODE_POOL \
  -o $OUT_POOL \
  --inline_index \
  --renz_1 $RENZ_1 \
  --renz_2 $RENZ_2 \
  -r -c -q

# Report demultiplexing summary for this pool
echo ""
echo "Demultiplexing complete for $POOL_NAME"
echo "Output FASTQ files: $(ls $OUT_POOL/*.fastq.gz 2>/dev/null | wc -l)"
echo ""

LOG=$(ls $OUT_POOL/process_radtags.*.log 2>/dev/null | head -1)
if [[ -f "$LOG" ]]; then
  echo "Demultiplexing summary:"
  echo "-----------------------"
  grep -A 999 "Barcode\tFilename" $LOG | head -50
  echo ""
  echo "Full log: $LOG"
else
  echo "WARNING: process_radtags log not found in $OUT_POOL"
fi
