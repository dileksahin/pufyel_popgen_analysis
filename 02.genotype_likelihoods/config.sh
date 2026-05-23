# config.sh — Genotype Likelihoods Pipeline
# Edit all paths below before running
# =============================================================================

# Software ANGSD executable directory
PROG_ANGSD="/path/to/angsd"                         

# Directories
# project working directory
WD="/path/to/working/directory"
# output directory for genotype likelihoods                   
OUT_GENO="$WD/genotype"                              
# directory containing sorted BAM files
BAM_DIR="/path/to/bam_output_directory"

# Reference genome
# Balearic Shearwater reference genome
# Cuevas-Caballé et al. (2021)
# BioProject: PRJNA780920
REF_GENOME="/path/to/reference_genome_directory"                

# Sites file (autosomal sites only — sex chromosomes excluded;
# showed strong clustering in initial PCA checks)
AUTOSOME_SITES="${PIPELINE_ROOT}/02.genotype_likelihoods/data/autosome_sites.txt"

# Population list
POP_LIST="${PIPELINE_ROOT}/02.genotype_likelihoods/data/pop.list"

# full list of sorted BAM file paths                          
BAM_LIST="$WD/bam.list"                           

# ANGSD parameters
GL=1                    # genotype likelihood model: SAMtools model
DO_MAJOR_MINOR=1        # infer major/minor allele from genotype likelihoods
DO_MAF=1                # calculate allele frequencies
DO_GLF=2                # output beagle genotype likelihood format
DO_COUNTS=1		# calculate raw allele frequencies and site-specific base counts directly from sequence data
MIN_MAPQ=10             # minimum mapping quality
MIN_Q=20                # minimum base quality
SNP_PVAL=1e-12          # p-value threshold for SNP calling
MIN_MAF=0.05            # minimum minor allele frequency
NTHREADS=16             # number of threads for ANGSD

# Minimum individuals threshold (set dynamically in 03_genotype_likelihoods.sh)
# Sites must be present in at least 50% of individuals (nInd/2)
