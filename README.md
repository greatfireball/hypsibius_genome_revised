# hypsibius_genome_revised

## kmer analysis

### splitting the large files

### merging kmers

### count kmer flags
```bash
user@localhost:~/$ pv kmer_dump.combined[ACGT][ACGT] | \
		      grep -v "^#" | \
		      cut -f6 | \
		      perl -ne '
   		      	   $hash{int($_)}++;
				END{
					foreach (sort {$a <=> $b} (keys %hash)) {
						print "$_\t$hash{$_}\n";
					}
				}' > kmer_flags.csv
user@localhost:~/$ cat kmer_flags.csv
1       370413642
2       114784882
3       90867856
4       72497790
5       36554284
6       4218572
7       65627638
8       164060771
9       18705784
10      2229659
11      8453157
12      1111634
13      3367073
14      223451
15      101270041
```
### plotting kmer venn
```bash
```

### generating histograms
```bash
for i in A C G T
do
   for j in A C G T
   do
      mkdir -p "$i$j"
      cd "$i$j"

      ln -s ../kmer_dump.combined"$i$j" ./input

      perl ~/hypsibius_genome_revised/kmer_intersection/generate_hist.pl ./input&
      cd ..
   done
done

for i in 300 500 800 mol all
do
   for j in filtered unfiltered
   do
	find -name "$i"_"$j" | xargs perl -aF'/\t/' -ne '
	     $hash{int($F[0])}+=int($F[1]);
	     END {
	     	 foreach (sort {$a <=> $b} (keys %hash))
		 {
			print "$_\t$hash{$_}\n";
		 }
	     }
	    ' > output_"$i"_"$j".csv
   done
done
```

### new kmer-plots
```bash
pdf("/tmp/kmerplot.pdf")

dat1<-read.table("/tmp/filtering/output_300_unfiltered.csv")
dat2<-read.table("/tmp/filtering/output_300_filtered.csv")

dat3<-read.table("/tmp/filtering/output_500_unfiltered.csv")
dat4<-read.table("/tmp/filtering/output_500_filtered.csv")

dat5<-read.table("/tmp/filtering/output_800_unfiltered.csv")
dat6<-read.table("/tmp/filtering/output_800_filtered.csv")

dat7<-read.table("/tmp/filtering/output_mol_unfiltered.csv")
dat8<-read.table("/tmp/filtering/output_mol_filtered.csv")

dat9<-read.table("/tmp/filtering/output_all_unfiltered.csv")
dat0<-read.table("/tmp/filtering/output_all_filtered.csv")

col="red"
plot(dat1$V1,dat1$V2,ylim=c(1,6e6),xlim=c(1,250),col=col,type="l",main="kmer plot", xlab="coverage", ylab="frequency")
lines(dat2$V1,dat2$V2,col=col,lty="dotted")

col="blue"
lines(dat3$V1,dat3$V2,col=col)
lines(dat4$V1,dat4$V2,col=col,lty="dotted")

col="darkgreen"
lines(dat5$V1,dat5$V2,col=col)
lines(dat6$V1,dat6$V2,col=col,lty="dotted")

col="purple"
lines(dat7$V1,dat7$V2,col=col)
lines(dat8$V1,dat8$V2,col=col,lty="dotted")

col="black"
lines(dat9$V1,dat9$V2,col=col)
lines(dat0$V1,dat0$V2,col=col,lty="dotted")

legend("topright", fill=c("red", "blue", "darkgreen", "purple", "black"), legend=c("300", "500", "800", "mol", "all"))

dev.off()
```

## CEGMA run

### Slurm script

```bash
user@machine:/location/$ cat run_cegma.sh
#!/bin/bash

# set specific environmental variables
export CEGMA=/software/cegma
export PERL5LIB=/software/cegma/lib/:$PERL5LIB
export PATH=/software/geneid/bin/:/software/cegma/bin/:$PATH
export WISECONFIGDIR=/software/wise/wisecfg/

# how many threads can be used?
THREADS=32

INPUTFILEDIR=$(dirname $1)/
INPUTFILE=$(basename $1)

# run cegma for the given genome
# change to the folder
cd "$INPUTFILEDIR"
# create a directory
mkdir "$INPUTFILE"_cegma_run
cd "$INPUTFILE"_cegma_run

# change all sequence identifiers to avoid problems
sed '/^>/s/^>/>seq_/g' ../"$INPUTFILE" > "$INPUTFILE"

cegma --threads "$THREADS" --genome "$INPUTFILE" 2>&1 | tee "$INPUTFILE".log
```

### Run the slurm script for our assemblies
```bash
for i in HD_gen.*
do
   sbatch -wr5n01 -c 32 -p ngsgrid -o "$i".stdout -e "$i".stderr -J cegma_"$i" ./run_cegma.sh "$i"
done
```

