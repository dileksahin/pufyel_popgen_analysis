## 06.SAF_2dSFS_and_Fst
This pipeline runs SAF, 2dSFS and Fst analyses. Calculates folded two-dimensional site frequency spectrum (2dSFS) using the flag of -fold 1 as ancestral allele polarisation was not possible and reference genome is used as proxy for ancestral (-anc in SAF step). Fst is calculated following Bhatia et al (2013)'s using the realSFS flag -whichFst 1. This estimator is recommended for datasets with uneven sample sizes. Bootstraps Fst in sliding windows for 95% confidence intervals to assess significance: pairs where CI excludes 0 are significant.

### Software versions
- ANGSD V 0.940 (Korneliussen et al., 2014)
- R 4.x with ggplot2, dplyr

### Usage
1. Edit config.sh to set paths for your system
2. Submit: bash run_saf_2dsfs_fst_pipeline.sh
