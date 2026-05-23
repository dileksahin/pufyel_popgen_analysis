# config.sh — PCA and Selection Pipeline
# Edit all paths below before running
# =============================================================================

# Software PCAngsd executable directory
# PCangsd V 1.10 (Meisner and Albrechtsen, 2018)
PROG_PCANGSD="/path/to/pcangsd" 

# Directories
# project working directory
WD="/path/to/working/directory"
# output directory for PCA results      
OUT_PCA="$WD/pca"
# output directory for figures
OUT_PLOTS="$WD/pca/plots"

# Input files
# beagle genotype likelihood file (output of 02.genotype_likelihoods)
BEAGLE="$WD/genotype/ys50_autosome.beagle.gz"
# list of sample IDs (one per line, grouped by islands)
SAMPLE_LIST="${PIPELINE_ROOT}/03.PCA_and_selection/data/sample.list"
# population cluster file         
POP_CLST="${PIPELINE_ROOT}/03.PCA_and_selection/data/pop.clst"
# covariance matrix (output of PCAngsd)                 
COV_MATRIX="$OUT_PCA/ys50_autosome.cov"

# PCAngsd parameters
N_EIG=7           # number of significant eigenvalues
                  # arbitrarily set to 7 based on number of groups expected
THREADS=28        # number of threads for PCAngsd (match --cpus-per-task)
SELECTION_E=7     # number of eigenvectors for selection scan (pcadapt)

# PCA plot parameters
N_IND=188         # total number of individuals retained after quality filtering
PCS_TO_PLOT="1-2,2-3"   # principal component pairs to plot

# Population colour codes (order matches population names in sample.list)
# Populations: CZA FLE FPC FPQ FRI GGY ICA IMO ILA ISD IST ITA MCO MGO MMA TZE
COLOR_CODES='c("brown", "#2b6fbb", "#6e4dc2", "#4c5cc5",
               "#1c8c9a", "#000000", "#f48eb7", "#f9b5cf",
               "#ec0089", "#ffdae8", "#c9cac8", "#d30075",
               "#fecb00", "#ffe9b6", "#ff8112", "#08d43d")'
