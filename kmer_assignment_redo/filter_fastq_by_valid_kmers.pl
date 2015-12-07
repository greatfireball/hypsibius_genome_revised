#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;

use jellyfish;

our $VERSION = '0.1';

my %options = ();

GetOptions(
    'i|infile=s@' => \$options{inputfiles},
    'o|output=s'  => \$options{outputfile},
    'k|kmerlib=s%' => \$options{kmerlibs}
    ) || die ("Error in command line arguments\n");

# prepare input files
$options{inputfiles} = [ split(',', join(",", @{$options{inputfiles}})) ];

# same for the kmerlib files
foreach my $kmerlib (keys %{$options{kmerlibs}})
{
    $options{kmerlibs}{$kmerlib} = [ map { { filename => $_, jellyfish_obj => undef } } split(',', $options{kmerlibs}{$kmerlib}) ];

    # create a jellyfish object for each input file
    foreach my $file (@{$options{kmerlibs}{$kmerlib}})
    {
	$file->{jellyfish_obj} = jellyfish::QueryMerFile->new($file->{filename});
    }
}

# open the output file
my $outfh = undef;
if (exists $options{outputfile} && defined $options{outputfile})
{
    open($outfh, ">", $options{outputfile}) || die "Unable to open output file '$options{outputfile}': $!";
    $options{outputfile} = { filename => $options{outputfile}, fh => $outfh};
}

# go through the input files
foreach my $inputfile (@{$options{inputfiles}})
{
    open(INPUT, "<", $inputfile) || die "Unable to open input file '$inputfile': $!";

    while(! eof(INPUT))
    {

	my ($header, $seq, $header2, $qual) = (scalar <INPUT>, scalar <INPUT>, scalar <INPUT>, scalar <INPUT>);

	chomp($header);
	chomp($seq);
	chomp($header2);
	chomp($qual);

	# create the kmers and check for each kmer if the kmer is present
	my ($num_kmers, $num_valid_kmers) = (0, 0);
	my @kmer_counts = ();

	foreach my $k (kmerize($seq, 19))
	{
	    $num_kmers++;

	    my ($valid_kmer, $kmer_count) = get_validity_and_kmer_count($k);
	    if ($valid_kmer)
	    {
		$num_valid_kmers++;
	    }

	    push(@kmer_counts, $kmer_count);
	}

	my $percentage_valid_kmers = $num_valid_kmers/$num_kmers;
	my ($mean_coverage, $median_coverage) = calc_mean_median(\@kmer_counts);
	if ($percentage_valid_kmers >= 0.95)
	{
	    printf $outfh, "%s percent_valid:%.5f mean_coverage:%.1f median_coverage:%.1f\n%s\n%s\n%s\n",
	    $header, $percentage_valid_kmers, $mean_coverage, $median_coverage, $seq, $header2, $qual;
	}
    }

    close(INPUT) || die "Unable to close input file '$inputfile': $!";
}

# close the output file
close($outfh) || die "Unable to close output file '$options{outputfile}': $!";

sub kmerize
{
    my ($seq, $size) = @_;

    my @kmers = ();

    for (my $i=0; $i<=length($seq)-$size; $i++)
    {
	my $kmer = substr($seq, $i, $size);

	my $rev_kmer = reverse $kmer;
	$rev_kmer =~ tr/AGCT/TCGA/;

	if ($kmer lt $rev_kmer)
	{
	    push(@kmers, $kmer);
	} else {
	    push(@kmers, $rev_kmer);
	}
    }

    return @kmers;
}

sub get_validity_and_kmer_count
{
    my ($kmer) = @_;

    my ($valid_kmer, $kmercount) = (0, 0);

    my %kmer_groups = ();

    my $mer = jellyfish::MerDNA->new($kmer);
    $mer->canonicalize();

    foreach my $kmerlib (keys %{$options{kmerlibs}})
    {
	$kmer_groups{$kmerlib} = 0;

	foreach my $file (@{$options{kmerlibs}{$kmerlib}})
	{
	    $kmer_groups{$kmerlib} += $file->{jellyfish_obj}->get($mer);
	}
    }

    # kmercount is the sum of all kmer groups
    foreach my $group (keys %kmer_groups)
    {
	$kmercount += $kmer_groups{$group};
    }

    # valid_kmer is true, if all groups have a count > 0
    $valid_kmer = ((grep { $kmer_groups{$_} > 0 } (keys %kmer_groups))==(keys %kmer_groups)) ? 1 : 0;

    return ($valid_kmer, $kmercount);
}

sub calc_mean_median
{
    my ($array_ref) = @_;

    my @sorted = sort {$a <=> $b} (@{$array_ref});

    my ($median, $mean, $sum);

    foreach (@sorted)
    {
	$sum+=$_;
    }

    $mean = $sum/(@sorted+0);

    if (@sorted%2==0)
    {
	$median = ($sorted[int(@sorted/2)]+$sorted[int(@sorted/2)+1])/2;
    } else {
	$median = $sorted[int((@sorted+1)/2)];
    }

    return ($mean, $median);
}

__END__

=pod

=head1 NAME

filter_fastq_by_valid_mers.pl - Perl script to filter the content of a fastq file based on the occurence of its sequence kmers in different libraries

=head1 VERSION

This is the documentation for version 0.1

=head1 SYNOPSIS

    ./filter_fastq_by_valid_kmers.pl \
       --in input.fastq \
       --out filtered.fastq \
       --kmerlib LIB1=lib1_mer_19 \
       --kmerlib LIB2=lib2_mer_19_A,lib2_mer_19_B

=head1 DESCRIPTION

We want to filter reads from a fastq based on the occurence of the
kmers of its sequences be represented by multiple libraries.

=head1 PARAMETER

=over 4

=item --input FILE(S)

This gives the input file(s) which contain the sequences to be filtered.
This is mendatory, but can be multiple input files.

=item --output FILE

This file is used for the output of the filtering. If no file is given
the output will be put on STDOUT

=item --kmerlib FILE(S)

Indicate the location of kmer-hash file(s) belonging to one single
group of kmers. I assume that the kmer is present in all hashs of the
library. If not, it will result in a warning message, but the kmer is
still valid if present in all Libraries. Count values for kmers will
be reported for whole libraries. Valid kmers have to be represented in
all defined libraries.

=back

=head1 SEE ALSO

TODO

=head1 AUTHOR

Frank Foerster (E<lt>frank.foerster@uni-wuerzburg.deE<gt>)

=head1 LICENCE

TODO

=head1 HISTORY

=cut
