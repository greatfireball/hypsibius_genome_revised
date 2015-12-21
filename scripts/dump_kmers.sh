#!/bin/bash

cd kmer

# dumping the kmer hashes
for i in *_mer_19
do
   jellyfish dump --column --tab -o $(basename "$i").dump "$i"
done

# merging kmer hash information into a single perl hash
prepare_filter_fastq_by_valid_kmers.pl \
   --output kmer_hash.bin \
   --kmerlib 300=HD_gen.il_L300.trimmed_mer_19.dump \
   --kmerlib 500=HD_gen.il_L500.trimmed_mer_19.dump \
   --kmerlib 800=HD_gen.il_L800.trimmed_mer_19.dump \
   --kmerlib Moleculo=HD_gen.mo_L1-5.trimmed.formatted_mer_19.dump
