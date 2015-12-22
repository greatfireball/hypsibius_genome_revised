#!/bin/bash

mkdir genome_size_estimation
cd genome_size_estimation

ErrorCorrectReads.pl PHRED_ENCODING=33 READS_OUT=HD_gen.il_L300.out \
   KEEP_KMER_SPECTRA=1 MAX_MEMORY_GB=200G \
   PAIRED_READS_A_IN=../trimmed/HD_gen.il_L300.trimmed_P1.fastq \
   PAIRED_READS_B_IN=../trimmed/HD_gen.il_L300.trimmed_P2.fastq \
   THREADS=32 HAPLOIDIFY=TRUE

ErrorCorrectReads.pl PHRED_ENCODING=33 READS_OUT=HD_gen.il_L500.out \
   KEEP_KMER_SPECTRA=1 MAX_MEMORY_GB=200G \
   PAIRED_READS_A_IN=../trimmed/HD_gen.il_L500.trimmed_P1.fastq \
   PAIRED_READS_B_IN=../trimmed/HD_gen.il_L500.trimmed_P2.fastq \
   THREADS=32 HAPLOIDIFY=TRUE

ErrorCorrectReads.pl PHRED_ENCODING=33 READS_OUT=HD_gen.il_L800.out \
   KEEP_KMER_SPECTRA=1 MAX_MEMORY_GB=200G \
   PAIRED_READS_A_IN=../trimmed/HD_gen.il_L800.trimmed_P1.fastq \
   PAIRED_READS_B_IN=../trimmed/HD_gen.il_L800.trimmed_P2.fastq \
   THREADS=32 HAPLOIDIFY=TRUE

for i in ../trimmed/HD_gen.mo_L[12345]*.trimmed.fastq;
do
   ErrorCorrectReads.pl PHRED_ENCODING=33 READS_OUT=$(basename "$i" .fastq).out \
      KEEP_KMER_SPECTRA=1 MAX_MEMORY_GB=200G \
      UNPAIRED_READS_IN="$i" \
      THREADS=32 HAPLOIDIFY=TRUE
done

for i in ../trimmed/HD_gen.mo_L[1]*.trimmed.fastq;
do
   ErrorCorrectReads.pl PHRED_ENCODING=33 READS_OUT=$(basename "$i" .fastq).out \
      KEEP_KMER_SPECTRA=1 MAX_MEMORY_GB=200G \
      UNPAIRED_READS_IN="$i" \
      THREADS=32 HAPLOIDIFY=TRUE
done
