#!/bin/bash

cd kmer_filtered

pv HD_gen.il_L300.trimmed_P12.interleave.kmerfiltered.fastq | \
   perl -ne '
      unless (/percent_valid:([\d.]+)/) { die "Fehler"; }

      if ($1 < 0.95) {
        print STDERR $_, scalar <>,
                     scalar <>, scalar <>,
                     scalar <>, scalar <>,
                     scalar <>, scalar <>;
      } else {
        print $_,scalar <>,
              scalar <>, scalar <>,
              scalar <>, scalar <>,
              scalar <>, scalar <>;
      }' 2> HD_gen.il_L300.trimmed_P12.interleave.kmerfiltered.untrusted.fastq \
          > HD_gen.il_L300.trimmed_P12.interleave.kmerfiltered.trusted.fastq

pv HD_gen.il_L500.trimmed_P12.interleave.kmerfiltered.fastq | \
   perl -ne '
      unless (/percent_valid:([\d.]+)/) { die "Fehler"; }

      if ($1 < 0.95) {
        print STDERR $_, scalar <>,
                     scalar <>, scalar <>,
                     scalar <>, scalar <>,
                     scalar <>, scalar <>;
      } else {
        print $_,scalar <>,
              scalar <>, scalar <>,
              scalar <>, scalar <>,
              scalar <>, scalar <>;
      }' 2> HD_gen.il_L500.trimmed_P12.interleave.kmerfiltered.untrusted.fastq \
          > HD_gen.il_L500.trimmed_P12.interleave.kmerfiltered.trusted.fastq

pv HD_gen.il_L800.trimmed_P12.interleave.kmerfiltered.fastq | \
   perl -ne '
      unless (/percent_valid:([\d.]+)/) { die "Fehler"; }

      if ($1 < 0.95) {
        print STDERR $_, scalar <>,
                     scalar <>, scalar <>,
                     scalar <>, scalar <>,
                     scalar <>, scalar <>;
      } else {
        print $_,scalar <>,
              scalar <>, scalar <>,
              scalar <>, scalar <>,
              scalar <>, scalar <>;
      }' 2> HD_gen.il_L800.trimmed_P12.interleave.kmerfiltered.untrusted.fastq \
          > HD_gen.il_L800.trimmed_P12.interleave.kmerfiltered.trusted.fastq
