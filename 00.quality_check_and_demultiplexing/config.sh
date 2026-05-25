# config.sh — Quality Check and Demultiplexing Pipeline
# Edit all paths before running
# =============================================================================

# Software
# Stacks v2.58 executable directory
PROG_STACKS="/path/to/stacks/bin"
# FastQC v0.12.0 executable
PROG_FASTQC="/path/to/fastqc"
# MultiQC executable
PROG_MULTIQC="/path/to/multiqc"        

# Directories
# Raw sequencing files — one directory per sequencing pool
RAW_POOL1="/path/to/raw_files/pool1"
RAW_POOL2="/path/to/raw_files/pool2"
RAW_POOL3="/path/to/raw_files/pool3"

# Top-level demultiplexing output directory
# Each pool writes to its own subdirectory: $OUT_DEMUX/pool1, pool2, pool3
OUT_DEMUX="/path/to/demultiplexed"

# output directory for FastQC reports
OUT_QC="/path/to/qc_reports"

# Barcode file (deposited in data/)
# Pool-specific barcode files (deposited in data/)
BARCODES_POOL1="${PIPELINE_ROOT}/00.quality_check_and_demultiplexing/data/pool1_barcodes.txt"
BARCODES_POOL2="${PIPELINE_ROOT}/00.quality_check_and_demultiplexing/data/pool2_barcodes.txt"
BARCODES_POOL3="${PIPELINE_ROOT}/00.quality_check_and_demultiplexing/data/pool3_barcodes.txt"

# process_radtags parameters
RENZ_1="pstI"          # primary restriction enzyme
RENZ_2="mseI"          # secondary restriction enzyme
                       # double-digest RADseq: pstI (rare cutter) + mseI (common cutter)

# FastQC parameters
FASTQC_THREADS=16      # number of threads for FastQC (match --cpus-per-task)
