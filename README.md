#A genome of a tardigrade --- Horizontal gene transfer or contamination

This repository comprises data set and scripts for our analysis of the manuscript [Boothby, et al. (2015)](#references).

##Content

- [Figures](#figures)
- [Material and Methods](#methods)
  - [GitHub repository](#github-repository)
  - [Data set](#data-set)
  - [Programs](#programs)
  - [Trimming of the input data](#trimming-of-the-input-data)
  - [Estimation of the genome size](#estimation-of-the-genome-size)
  - [Counting and Filtering bases on kmers](#counting-and-filtering-bases-on-kmers)
  - [Long Read Assembly](#long-read-assembly)
  - [Assembly Annotation](#assembly-annotation)
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
  [Boothby, et al. (2015)](#references)*

##Methods
###GitHub repository

All script files are available from our GitHub repository
https://github.com/greatfireball/hypsibius_genome_revised/.

###Data set
We used the data set provided by [Boothby, et al. (2015)](#references) and downloaded
the data from http://weatherby.genetics.utah.edu/seq_transf/. A
complete list of the used input files are given in the following table:

**Table S1:** *Data set used for our analysis including checksums for compressed and decompressed file content.*

| Filename and location | Modification time  | Size in Bytes  | MD5 check sum | MD5 check sum decompressed |
|:---------------------:|:------------------:|---------------:|:-------------:|:--------------------------:|
| [tg.genome.fsa.gz](http://weatherby.genetics.utah.edu/seq_transf/tg.genome.fsa.gz) | 2015-11-25T01:34:44Z | 72215266 | b8bd39390ef35dd43d1cda1ca6944d5a | 77be374d28b91232c0810cc4d3cd37b9 |
| [tg.default.maker.proteins.final.fasta.gz](http://weatherby.genetics.utah.edu/seq_transf/tg.default.maker.proteins.final.fasta.gz) | 2015-12-02T23:43:44Z | 12359873 | 2de12e5d28d6dba121973db2071565d9 | 1ad17cfa9e6c26e552fa8048c6ee90af |
| [short\_reads/TG-300-SIPE\_1\_sequence.txt](http://weatherby.genetics.utah.edu/seq_transf/short_reads/TG-300-SIPE_1_sequence.txt) | 2015-11-30T21:48:51Z | 11526955725 | c16b5442c9893b6feaa3aa81a39eefcd | c16b5442c9893b6feaa3aa81a39eefcd |
| [short\_reads/TG-300-SIPE\_2\_sequence.txt.gz](http://weatherby.genetics.utah.edu/seq_transf/short_reads/TG-300-SIPE_2_sequence.txt.gz) | 2015-11-30T21:52:41Z | 3920224257 | 3bea43d66d71926fb620966d281598c6 | bc8423d4fe4275863e0809445ffd21ce |
| [short\_reads/TG-500-SIPE\_1\_sequence.txt.gz](http://weatherby.genetics.utah.edu/seq_transf/short_reads/TG-500-SIPE_1_sequence.txt.gz) | 2015-12-01T05:32:05Z | 2738243219 | da8b15d388961938584343f8926f7b24 | eee7363557ccb1fb0fa75ebe55ae7ee5 |
| [short\_reads/TG-500-SIPE\_2\_sequence.txt.gz](http://weatherby.genetics.utah.edu/seq_transf/short_reads/TG-500-SIPE_2_sequence.txt.gz) | 2015-12-01T05:35:15Z | 2805269168 | aa8c2c345484b9464d272e0993d6968b | 325d74bbafd9b6019609e2fd33eca260 |
| [short_reads/TG-800-SIPE_1_sequence.txt.gz](http://weatherby.genetics.utah.edu/seq_transf/short_reads/TG-800-SIPE_1_sequence.txt.gz) | 2015-12-01T05:36:55Z | 2155735304 | 6e9cce1a27000ae2b4f87181a976df92 | a85568ef53979c367870eee6390f2ced |
| [short\_reads/TG-800-SIPE\_2\_sequence.txt.gz](http://weatherby.genetics.utah.edu/seq_transf/short_reads/TG-800-SIPE_2_sequence.txt.gz) | 2015-12-01T05:37:46Z | 2058207374 | ccf097cf4f13bb5cbc5a8e002250093d | 4a4cc02c2f289d59c300810fb621eb28 |
| [moleculo\_reads/LR6000049-DNA\_A01-LRAAD-01\_LongRead.fastq.gz](http://weatherby.genetics.utah.edu/seq_transf/moleculo_reads/LR6000049-DNA_A01-LRAAD-01_LongRead.fastq.gz) | 2015-11-30T17:50:17Z | 825877986 | 86e75544f2d6ef5185bae419bbd2a4b2 | bace73ed4750b33fc144e56c155454ab |
| [moleculo\_reads/LR6000049-DNA\_A01-LRAAD-02\_LongRead.fastq.gz](http://weatherby.genetics.utah.edu/seq_transf/moleculo_reads/LR6000049-DNA_A01-LRAAD-02_LongRead.fastq.gz) | 2015-11-30T17:51:34Z | 835283315 | 4dea3e39a7a25059a6ebbd5588e845b2 | cb83c39f9a385f0b4fd1e507cfe40ff1 |
| [moleculo\_reads/LR6000049-DNA\_A01-LRAAD-03\_LongRead.fastq.gz](http://weatherby.genetics.utah.edu/seq_transf/moleculo_reads/LR6000049-DNA_A01-LRAAD-03_LongRead.fastq.gz) | 2015-11-30T17:52:51Z | 847867943 | 16276b6ef8dea90721eb67ac21d616e6 | 51d4ce37668684b4aa25e061fb95b4ef |
| [moleculo\_reads/LR6000049-DNA\_A01-LRAAD-04\_LongRead.fastq.gz](http://weatherby.genetics.utah.edu/seq_transf/moleculo_reads/LR6000049-DNA_A01-LRAAD-04_LongRead.fastq.gz) | 2015-11-30T17:56:08Z | 859746540 | 3364040445c7377c9323f82d98a2258c | dbe06ec4248199f416bb1d02ff1e65f5 |
| [moleculo\_reads/LR6000049-DNA\_A01-LRAAD-05\_LongRead.fastq.gz](http://weatherby.genetics.utah.edu/seq_transf/moleculo_reads/LR6000049-DNA_A01-LRAAD-05_LongRead.fastq.gz) | 2015-11-30T17:56:51Z | 854266597 | 7995559df803ef0de0250f1bfac71f1a | 98d30f3ceb813d9f53c6df2ed1fa2239

###Programs

**Table S2:** *List of all programs including the version numbers and references to publications or websites used for the data processing and analysis*

| Programname | Version | Reference |
|:-----------:|:-------:|:----------|
Allpath-LG  | v50378 | Gnerre2011, Ribeiro2012 |
BEDTools    | v2.20.1 |  Quinlan2010 |
bioperl     | v1.69.1 | Stajich2002 |
bowtie2     | v2.2.2 | Langmead2012 |
bwa         | v0.7.10 | Li2009a,Li2010 |
CGView      | v1.0 | Grin2011 |
Falcon      | v0.4.0 | https://github.com/PacificBiosciences/falcon |
Genemark-S  | v4.3.2 | Besemer2001 |
Genemark-ET | v4.29 | Lomsadze2014 |
Jellyfish   | v2.2.4  | [Marcais and Kingsford (2011)](#references) |
Perl        | v5.14.2  | https://www.perl.org/ |
samtools    | v1.1 | Li2009b, Li2011a, Li2011b |
skewer      | v0.1.124 | Jiang2014 |
'sm' R package | v2.2-5.4 | Bowman2014 |
Trimmomatic | v0.3.5 | Bolger2014 |

###Trimming of the input data

Short reads were trimmed with skewer.

```bash
skewer -m pe -q 30 -Q 30 -l 60 -t 64 \
   HD_gen.il_L[358]*00_P1.fastq HD_gen.il_L[358]*00_P2.fastq
```

Long reads were trimmed with Trimmomatic.

```bash
java -jar trimmomatic-0.35.jar SE -phred33 HD_gen.mo_L[12345]*.fastq \
   HD_gen.mo_L[12345]*.trimmed.fastq \
   ILLUMINACLIP:adapter.fa:2:30:10 LEADING:30 TRAILING:30 MINLEN:250
```

###Estimation of the genome size

The genome size was estimated by the standalone error
correction pipeline of Allpaths-LG.

```bash
./scripts/genome_size_estimation.sh
```

###Counting and Filtering bases on kmers

The kmers of all libraries where counted using the software jellyfish
[Marcais and Kingsford (2011)](#references):

```bash
./scripts/count_kmers.sh
```

The resulting kmer hashes need to be dumped and converted to a hash
utilized later during the filtering step. This step and the following
required >200 \giga\byte of memory and was performed by the perl
script `prepare\_filter\_fastq\_by\_valid\_kmers.pl`.

```bash
./scripts/dump_kmers.sh
```

The generated hash was used to filter individual libraries. Therefore,
we have written the perl script
`filter\_fastq\_by\_valid\_kmers\_reduced.pl`.

```bash
./scripts/filter_input_data.sh
```

The filtered data sets are classified as 'trusted' or 'untrusted'
based on the 'trusted' kmer content. Reads with at least
95% 'trusted' kmers content are called 'trusted'
while reads below that threshold are classified as 'untrusted'.

```bash
./scripts/extract_classified_sequences.sh
```

###Long Read Assembly

Trusted and untrusted Moleculo reads were assembled with Falcon.

```bash
fc_run.py trusted.falcon.cfg
fc_run.py untrusted.falcon.cfg
```

See configuration files for parameter details.

###Assembly Annotation
The trusted assembly was annotated with GeneMark-ES.

```bash
gmes_petap.pl --sequence HD_gen.trusted.fasta \
   --ES --cores 64
```

The untrusted assembly was annotated with GeneMark-S

```bash
gmsn.pl --fnn --faa --species HD --gm \
   --name HD HD_gen.unsupported.fasta
```

The largest untrusted sequence was visualized using the CGView Server.


##References

- Boothby, et al. (2015)
- Marcais and Kingsford (2011)