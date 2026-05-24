## 05.admixture
In this pipeline runs admixture analyses to determine the ancestry between populations, using genotype likelihoods. Admixture is a model-based clustering analysis and estimates ancestral proportions of each individual by assuming a model of discrete ancestral populations, which is represented with K. Admixture was run for K= 1 to 14 and for 10 replicates for each K value. Pritchard et al. (2000) and Evanno et al. (2005)’s methods were implemented using log likelihood of each K in these replicates to determine the most likely K.

### Software versions
- NGSadmix V 32 (Skotte et al., 2013)
- EvalAdmix V 0.95 (Garcia-Erill et al., 2020)

### Usage
1. Edit config.sh to set paths for your system
2. Submit: bash run_admixture_pipeline.sh
