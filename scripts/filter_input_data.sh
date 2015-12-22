#!/bin/bash

mkdir kmer_filtered
cd kmer_filtered
../scripts/filter_fastq_by_valid_kmers.pl \
   --infile ../trimmed/HD_gen.il_L300.trimmed_P1.fastq,../trimmed/HD_gen.il_L300.trimmed_P2.fastq \
   --kmerhash ../kmer/kmers_hash.bin \
   --out HD_gen.il_L300.trimmed_P12.fastq.interleaved.filtered \
   --paired

../scripts/filter_fastq_by_valid_kmers.pl \
   --infile ../trimmed/HD_gen.il_L500.trimmed_P1.fastq,../trimmed/HD_gen.il_L500.trimmed_P2.fastq \
   --kmerhash ../kmer/kmers_hash.bin \
   --out HD_gen.il_L500.trimmed_P12.fastq.interleaved.filtered \
   --paired

../scripts/filter_fastq_by_valid_kmers.pl \
   --infile ../trimmed/HD_gen.il_L800.trimmed_P1.fastq,../trimmed/HD_gen.il_L800.trimmed_P2.fastq \
   --kmerhash ../kmer/kmers_hash.bin \
   --out HD_gen.il_L800.trimmed_P12.fastq.interleaved.filtered \
   --paired

for i in $(find ../trimmed/ -name HD_gen.mo_L[12345]*.trimmed.formatted.fastq)
do
   ../scripts/filter_fastq_by_valid_kmers.pl \
      --infile "$i" \
      --kmerhash ../kmer/kmers_hash.bin \
      --out $(basename "$i").filtered
done

# combine all moleculo data into a single file
cat HD_gen.mo_L[12345]*.trimmed.formatted.fastq.filtered > HD_gen.mo_L12345.trimmed.kmerfiltered.fastq
