## 01. Mapping

### Reference genome
Balearic Shearwater (*Puffinus mauritanicus*) genome
Cuevas-Caballé et al. (2021)
BioProject: PRJNA780920
BioSamples: SAMN24039388, SAMN23492024, SAMN23212142

### Software versions
- BWA v0.7.17 (Li and Durbin, 2009)
- Samtools v1.17 (Danecek et al., 2021)
- GATK Picard Tools v3.0.0 (Broad Institute, 2023)
- fastq_pair v1.0 (Edwards and Edwards, 2019)

### Usage
1. Edit config.sh to set paths for your system
2. Submit: bash run_mapping_pipeline.sh

### Read-group fields (data/read-groups.tsv)
- ID: {SampleID}_{LibraryNumber}_{Flowcell}_{Lane}
- SM: Sample name
- LB: Library number (used to scope PCR duplicate marking per library preparation)
- PU: Platform unit — {Flowcell}_{Lane}
- PL: Sequencing platform (Illumina)

### Quality filtering
Samples with <90% aligned reads or <100,000 aligned reads were excluded,
resulting in 188 samples retained for downstream analyses.

#### Note: 12 samples had mismatched forward/reverse read order in fastq files; fixed using fastq_pair v1.0 (Edwards and Edwards, 2019) before alignment
