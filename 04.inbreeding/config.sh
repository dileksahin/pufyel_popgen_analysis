# config.sh — Inbreeding Coefficient Pipeline
# Edit all paths below before running
# =============================================================================

# Software
# ANGSD executable directory
PROG_ANGSD="/path/to/angsd"
# ngsF executable directory
PROG_NGSF="/path/to/ngsF"

# Directories
# project working directory
WD="/path/to/working/directory"
# genotype output directory
OUT_GENO="$WD/genotype"
# output directory for inbreeding results
OUT_INBREEDING="$WD/inbreeding"
# Balearic Shearwater reference genome
# Cuevas-Caballé et al. (2021)
# BioProject: PRJNA780920
REF_GENOME="/path/to/refgenome"
                                        

# Input files
# Note: bam.list contains all individual BAM files for inbreeding analysis
BAM_LIST="$WD/bam.list"

# Output file prefixes
GLF_PREFIX="$OUT_GENO/ys50_autosome_FIS"        # GLF output prefix (ANGSD)
NGSF_OUT="$OUT_INBREEDING/ys50_autosome_indF"   # ngsF output prefix
MAFS_FILE="$OUT_GENO/ys50_autosome.mafs.gz"     # mafs file from 02.genotype_likelihoods
                                                 # used to count variable sites for ngsF

# ANGSD parameters for GLF generation
GL=1            # SAMtools genotype likelihood model
DO_GLF=3        # output binary GLF format required by ngsF
                # (format 3 = 3*n_ind*n_sites doubles in binary)
DO_MAJOR_MINOR=1
DO_MAF=1
SNP_PVAL=1e-12  # stringent SNP p-value threshold; all sites must be variable for ngsF
MIN_MAF=0.05    # minimum minor allele frequency
MIN_MAPQ=10     # minimum mapping quality
MIN_Q=20        # minimum base quality
NTHREADS=16     # number of threads (match --cpus-per-task)

# ngsF parameters
N_IND=188               # number of individuals after quality filtering
INIT_VALUES="r"         # random starting points — required for low-coverage data
                        # as initial estimates are unreliable at low coverage
MIN_EPSILON=1e-9        # strict stopping criterion (range: 1e-6 to 1e-9)
                        # stricter threshold used because initial estimates
                        # are unreliable in low-coverage data
NGSF_THREADS=16         # number of threads for ngsF (match --cpus-per-task)
