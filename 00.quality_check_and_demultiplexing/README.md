## 00. Demultiplexing and Quality Check

> **Note for reproducibility:** Demultiplexed FASTQ files are provided directly
> for this study rather than raw sequencing files. The pipeline therefore starts
> at **01.mapping**. This pipeline is provided for transparency so that the
> complete processing history from raw reads to demultiplexed samples is
> documented and reproducible.

## Overview

Raw paired-end RADseq reads were demultiplexed into per-sample FASTQ files
using Stacks `process_radtags`, which simultaneously filters low-quality reads
and rescues reads with sequencing errors in the barcode or restriction enzyme
cut site. Sequence quality of demultiplexed files was assessed using FastQC,
with results aggregated across all samples using MultiQC.

### Software versions
- Stacks v2.58 process_radtags (Catchen et al., 2013)
- FastQC v0.12.0 (Andrews, 2010)

### Usage
1. Edit config.sh to set paths for your system
2. Submit: bash run_qc_demux_pipeline.sh

## Barcode file (`data/poolX_barcodes.txt`)

Barcodes follow the **inline+index** format: the P5 barcode is inline within
the sequence read, and the i7 barcode is in the index read. The file has
three tab-delimited columns with no header:

| Column | Content | Example |
|--------|---------|---------|
| 1 | P5 adapter — 6-base inline barcode | `ACATCG` |
| 2 | i7 index — 6-base index sequence | `TGCATG` |
| 3 | Sample name | `CZA04` |
