# config.sh — edit these paths before running

# Indexing reference genome
PROG_BWA= "/path/to/bwa_software"
REF_GENOME= "/path/to/reference_genome_directory"
INDEXED_GENOME= "/path/to/indexed_genome_directory"
PROG_SAM="/path/to/samtools_software"

# Alignment
OUT_SAM= "/path/to/sam_output_directory"
OUT_BAM= "/path/to/bam_output_directory"

# Read groups data stored in GitHub Repository
READ_GROUPS_TSV="${PIPELINE_ROOT}/01.mapping/data/read-groups.tsv"

#Validating BAM files
# Java settings for Picard
# 8GB heap; adjust to your node's memory
JAVA_HEAP="-Xmx8g"                              

# Picard, full path to versioned jar
PICARD_JAR="/path/to/picard/3.0.0/picard.jar" 
OUT_VALIDATE="/path/to/validation_output" 

# Alignment statistics
OUT_ALI_STATS= "/path/to/alignment_stats_output_directory"
