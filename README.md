#A genome of a tardigrade --- Horizontal gene transfer or contamination

This repository comprises data set and scripts for our analysis of the manuscript [Boothby, et al. (2015)](#References).

##Content

- [Figures](#figures)
- [Material and Methods](#methods)
- [References](#references)

##Figures

![Image](https://cdn.rawgit.com/greatfireball/hypsibius_genome_revised/master/supplement/figures/supplementary_figure_1.svg)

**Figure S1: kmer Analysis** *The plots depict the kmer
  distribution for each library before (black line) and after
  classification into 'trusted' (green line) and 'untrusted' kmers
  (red line).*
  
![Image](https://cdn.rawgit.com/greatfireball/hypsibius_genome_revised/master/supplement/figures/supplementary_figure_2.svg)

**Figure S2: Assembly Feature Comparisons** *A) Per-site coverage
  of trusted and untrusted assembly based on mappings of Moleculo
  reads. Contigs from the untrusted assembly generally don't share the
  coverage of the trusted, most likley nuclear, genome. B) GC content
  of trusted and untrusted assembly estimated using sliding window
  approach. The untrusted assembly contains multiple peaks pointing
  towards contig subpopulations with different GC content. C) Per-site
  variability of trusted und untrusted assembly which can serve as
  ploidy proxy. The untrusted variability spectrum seems distored and
  contains a multiude of different peaks while the trusted assembly
  shows a typical diploid spectrum. D) Length distribution of
  intergenetic regions. Intragenetic regions are significantly larger
  in the trusted assembly than in the trusted.*
  
  ![Image](https://cdn.rawgit.com/greatfireball/hypsibius_genome_revised/master/supplement/figures/supplementary_figure_3.svg)

**Figure S3: Unknown Bacterial Genome** *Circular map of an
  unknown bacterial genome probably belonging to the Chitinophagaceae
  drawn with CGView. Tracks 1 and 2 (blue) indicate GeneMark-S annotated
  genes on forward and reverse strand. Track 3 (red) visualizes
  regions of homology to a set of 30,844 Chitinophagaceae proteins
  downloaded from UniProtKB. Track 4 (green) shows homology between
  GeneMark-S predicted proteins and the published protein set of
  [Boothby, et al. (2015)](#References)*

##Methods
###GitHub repository

All script files are available from our GitHub repository
https://github.com/greatfireball/hypsibius_genome_revised/.

###Data set
We used the data set provided by [Boothby, et al. (2015)](#References) and downloaded
the data from http://weatherby.genetics.utah.edu/seq_transf/. A
complete list of the used input files are given in the following table:


**Table S1:** *Data set used for our analysis including checksums for compressed and decompressed file content.*

| Filename and location | Modification time  | Size in Bytes  | MD5 check sum | MD5 check sum decompressed |
|:---------------------:|:------------------:|---------------:|:-------------:|:--------------------------:|
| [tg.genome.fsa.gz](http://weatherby.genetics.utah.edu/seq_transf/tg.genome.fsa.gz) | 2015-11-25T01:34:44Z | 72215266 | b8bd39390ef35dd43d1cda1ca6944d5a | 77be374d28b91232c0810cc4d3cd37b9 |
| [tg.default.maker.proteins.final.fasta.gz](http://weatherby.genetics.utah.edu/seq_transf/tg.default.maker.proteins.final.fasta.gz) | 2015-12-02T23:43:44Z | 12359873 | 2de12e5d28d6dba121973db2071565d9 | 1ad17cfa9e6c26e552fa8048c6ee90af |
| [short\_reads/TG-300-SIPE\_1\_sequence.txt)](http://weatherby.genetics.utah.edu/seq_transf/short_reads/TG-300-SIPE_1_sequence.txt) | 2015-11-30T21:48:51Z | 11526955725 | c16b5442c9893b6feaa3aa81a39eefcd | c16b5442c9893b6feaa3aa81a39eefcd |

##References

- Boothby, et al. (2015)