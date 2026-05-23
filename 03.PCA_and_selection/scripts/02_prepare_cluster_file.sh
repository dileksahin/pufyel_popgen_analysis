#!/bin/bash
#SBATCH --job-name=prepare_clusters
#SBATCH --output=logs/prepare_clusters.log
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:30:00
#SBATCH --dependency=afterok:<pcangsd_jobid>

source config.sh

# Prepare population cluster file for PCA plotting
# Output file (pop.clst) has three columns:
#   FID     individual index (1..N)
#   IID     individual index (1..N, used as row identifier in R)
#   CLUSTER population name extracted from sample IDs (characters 1-3)
#             e.g. sample ID "CZA04" -> CLUSTER = "CZA"
#
# Note: character positions in cut -c1-3 assume a fixed sample ID format.
# Verify against your sample.list before running.

N_IND=$(wc -l < $SAMPLE_LIST)

# Extract population labels from sample IDs (characters 3-5)
cut -c1-3 $SAMPLE_LIST | sed '1i CLUSTER' > $WD/CLUSTER

# Generate sequential individual indices for FID and IID columns
seq $N_IND | sed '1i FID' > $WD/FID
seq $N_IND | sed '1i IID' > $WD/IID

# Combine into space-delimited cluster file
paste -d' ' $WD/FID $WD/IID $WD/CLUSTER > $POP_CLST

# Clean up intermediate files
rm $WD/FID $WD/IID $WD/CLUSTER
