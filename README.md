# hypsibius_genome_revised

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
