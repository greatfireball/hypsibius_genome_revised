#!/bin/bash

mkdir mapping
cd mapping

BWA=bwa
SAMTOOLS=samtools

ln -s ../assemblies/HD*.fasta ./

# prepare mapping indices for bowtie2 and bwa
for i in *.fasta
do
   # bowtie2 preparation
   bowtie2-build "$i" \
      $(basename "$i" .fasta) 2>&1 | \
      tee bowtie2-build-$(basename "$i" .fasta).log
   # bwa preparation
   bwa index "$i" 2>&1 | \
      tee bwa-index-$(basename "$i" .fasta).log
done

# mapping of short reads
for REF in HD_gen.supported.fasta HD_gen.unsupported.fasta
do
   # 300 bp library
   bowtie2 \
        -x "$REF" \
        -1 ../trimmed/HD_gen.il_L300.trimmed_P1.fastq \
        -2 ../trimmed/HD_gen.il_L300.trimmed_P2.fastq \
        -p 32 \
        --minins 0 \
        --maxins 900 | \
        samtools view -uS - | \
        samtools sort -@32 - "$REF"-il.L300

   # 500 bp library
   bowtie2 \
        -x "$REF" \
        -1 ../trimmed/HD_gen.il_L500.trimmed_P1.fastq \
        -2 ../trimmed/HD_gen.il_L500.trimmed_P2.fastq \
        -p 32 \
        --minins 0 \
        --maxins 1500 | \
        samtools view -uS - | \
        samtools sort -@32 - "$REF"-il.L500

   # 800 bp library
   bowtie2 \
        -x "$REF" \
        -1 ../trimmed/HD_gen.il_L800.trimmed_P1.fastq \
        -2 ../trimmed/HD_gen.il_L800.trimmed_P2.fastq \
        -p 32 \
        --minins 0 \
        --maxins 2400 | \
        samtools view -uS - | \
        samtools sort -@32 - "$REF"-il.L800
done

# mapping of long reads
# combine all long reads
find ../trimmed/ -name "HD_gen.mo_L[12345].trimmed.formatted.fastq" | \
   xargs cat > ../trimmed/HD_gen.mo_L12345.trimmed.formatted.fastq

# map the longreads
for REF in HD_gen.supported.fasta HD_gen.unsupported.fasta
do
   for SEQ in ../trimmed/HD_gen.mo_L12345.trimmed.formatted.fastq
      OUT=$(basename "$REF")_$(basename "$SEQ")

      $BWA mem -t 32 "$REF" "$SEQ" | \
      $SAMTOOLS view -uS - | \
      $SAMTOOLS sort -@32 - "$OUT"
   done
done

# extraction of per base coverage
for REF in HD_gen.supported.fasta HD_gen.unsupported.fasta
do
   for BAM in "$REF"*.bam
   do
      OUT=$(basename "$BAM" .bam).cov
      bedtools genomecov \
         -ibam "$BAM" -d -g "$REF" > "$OUT"
   done
done
