#!/bin/bash

# counting the kmers inside the trimmed sequence libraries
mkdir kmer
cd kmer
jellyfish count -t 32 -m 19 -s 30G -C \
   -o HD_gen.il_L300.trimmed_mer_19 \
   ../trimmed/HD_gen.il_L300.trimmed_P1.fastq \
   ../trimmed/HD_gen.il_L300.trimmed_P2.fastq
jellyfish count -t 32 -m 19 -s 30G -C \
   -o HD_gen.il_L500.trimmed_mer_19 \
   ../trimmed/HD_gen.il_L500.trimmed_P1.fastq \
   ../trimmed/HD_gen.il_L500.trimmed_P2.fastq
jellyfish count -t 32 -m 19 -s 30G -C \
   -o HD_gen.il_L800.trimmed_mer_19 \
   ../trimmed/HD_gen.il_L800.trimmed_P1.fastq \
   ../trimmed/HD_gen.il_L800.trimmed_P2.fastq
for i in $(find ../trimmed/ -name HD_gen.mo_L[12345]*.trimmed.formatted.fastq)
do
    jellyfish count -t 32 -m 19 -s 30G -C -o $(basename "$i" .fastq)_mer_19 "$i"
done

# merging of the moleculo hashes
jellyfish merge \
   -o HD_gen.mo_L1-5.trimmed.formatted_mer_19 \
   HD_gen.mo_L[12345].trimmed.formatted_mer_19
