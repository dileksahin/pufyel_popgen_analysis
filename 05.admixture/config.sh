# config.sh — Admixture Pipeline
# Edit all paths below before running
# =============================================================================

# Software
# NGSadmix executable directory
PROG_NGSADMIX="/path/to/NGSadmix"
# evalAdmix executable directory      
PROG_EVALADMIX="/path/to/evalAdmix"

# Directories
WD="/path/to/working/directory"
OUT_ADMIX="$WD/admixture"              # output directory for NGSadmix results
OUT_BESTREPS="$OUT_ADMIX/bestReps"     # output directory for best replicate qopt files
OUT_PLOTS="$OUT_ADMIX/plots"           # output directory for figures

# Input files
# Beagle file from 02.genotype_likelihoods
BEAGLE="$WD/genotype/ys50_autosome.beagle.gz"
# Inbreeding coefficients from 04.inbreeding (used as prior in NGSadmix)
INDF="$WD/inbreeding/ys50_autosome_indF"

# Sample and group files (deposited in data/)
SAMPLE_LIST="${PIPELINE_ROOT}/03.PCA_and_selection/data/sample.list"
GROUPS_LIST="${PIPELINE_ROOT}/02.genotype_likelihoods/data/pop.list"
BAM_LIST="$WD/bam.list"

# NGSadmix parameters
INFILE_PREFIX="ys50_autosome"   # prefix of beagle file
K_MAX=14                        # maximum K to test
                                # set to 14 based on number of populations sampled
N_RUNS=10                       # number of independent runs per K value
                                # multiple runs required to assess convergence
NGSADMIX_THREADS=12             # threads per NGSadmix run (match --cpus-per-task)

# evalAdmix parameters
BOOTSTRAP=10                    # number of bootstrap replicates for model evaluation
EVALADMIX_THREADS=20            # threads for evalAdmix (match --cpus-per-task)

# Populations
POP_LIST="${PIPELINE_ROOT}/02.genotype_likelihoods/data/pop.list"

# R plot parameters
# Selected run indices for alignK (one best run per K, 1-14)
# Determined from evalAdmix model fit assessment (04_find_bestreps.sh)
# Update these after running evalAdmix, based on best run results
BEST_RUN_INDICES="10, 16, 23, 38, 46, 58, 70, 76, 89, 98, 101, 114, 127, 137"

# Population order for admixture plots
POP_ORDER="FRI TZE FPC FPQ FLE CZA IMO MCO MGO ITA ICA ISD ILA MMA IST GGY"
