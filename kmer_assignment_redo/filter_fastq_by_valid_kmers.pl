#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Term::ProgressBar;

use Storable;

our $VERSION = '0.1';

my %options = ();
my $kmer_cache = {};
my %missing_kmers = ();

GetOptions(
    'i|infile=s@' => \$options{inputfiles},
    'o|output=s'  => \$options{outputfile},
    'k|kmerhash=s' => \$options{kmerhash},
    'p|paired'     => \$options{paired}
    ) || die ("Error in command line arguments\n");

# prepare input files
$options{inputfiles} = [ split(',', join(",", @{$options{inputfiles}})) ];

# check if paired is set... I this case, we require an even number of input files
if ($options{paired} && @{$options{inputfiles}}%2!=0)
{
    die "Number of inputfiles is not even!\n";
}

# same for the kmerlib files
$kmer_cache = Storable::retrieve($options{kmerhash});

# open the output file
my $outfh = undef;
if (exists $options{outputfile} && defined $options{outputfile})
{
    open($outfh, ">", $options{outputfile}) || die "Unable to open output file '$options{outputfile}': $!";
    $options{outputfile} = { filename => $options{outputfile}, fh => $outfh};
}

# go through the input files
for (my $i = 0; $i < @{$options{inputfiles}}; $i++)
{
    my $inputfile = $options{inputfiles}->[$i];

    my $inputfile2;

    my $filesize = -s $inputfile;

    # if paired mode, we need the second input file
    if ($options{paired})
    {
	# increase the counter $i++;
	$i++;

	# now at position [$i] is the second file
	$inputfile2 = $options{inputfiles}->[$i];
	$filesize += -s $inputfile2;
    }

    my $progress = Term::ProgressBar->new(
	{
	    name  => 'Kmer File',
	    count => $filesize,
	    ETA   => 'linear',
	    term_width => 50,
	}
	);
    $progress->max_update_rate(1);
    my $update_block_size=50*1024*1024;
    my $next_update = $update_block_size;

    open(INPUT, "<", $inputfile) || die "Unable to open input file '$inputfile': $!";

    my $in2 = undef;
    if ($options{paired})
    {
	open($in2, "<", $inputfile2) || die "Unable to open input file '$inputfile2': $!";
    }

    while(!( eof(INPUT) || ( defined $in2 && eof($in2))))
    {

	my $pos = tell(INPUT);
	if ($options{paired})
	{
	    $pos += tell($in2);
	}

	if ( $pos > $next_update ) {
	    $progress->update( $pos );
	    $next_update += $update_block_size;
	}
	my ($header, $seq, $header2, $qual) = (scalar <INPUT>, scalar <INPUT>, scalar <INPUT>, scalar <INPUT>);

	chomp($header);
	chomp($seq);
	chomp($header2);
	chomp($qual);

	my ($second_header, $second_seq, $second_header2, $second_qual);

	if ($options{paired})
	{
	    ($second_header, $second_seq, $second_header2, $second_qual) = (scalar <$in2>, scalar <$in2>, scalar <$in2>, scalar <$in2>);

	    chomp($second_header);
	    chomp($second_seq);
	    chomp($second_header2);
	    chomp($second_qual);
	}

	# create the kmers and check for each kmer if the kmer is present
	my ($num_kmers, $num_valid_kmers, $num_unknown_kmers) = (0, 0, 0);
	my @kmer_counts = ();

	foreach my $k (kmerize($seq, 19))
	{
	    $num_kmers++;

	    my ($valid_kmer, $kmer_count) = get_validity_and_kmer_count($k);
	    if ($valid_kmer)
	    {
		$num_valid_kmers++;
	    }

	    # if kmer_count was -1 the kmer was unknown, therefore increase the counter and ignore that coverage for coverage calculation
	    if ($kmer_count == -1)
	    {
		$num_unknown_kmers++;
	    } else {
		push(@kmer_counts, $kmer_count);
	    }
	}

	if ($options{paired})
	{
	    foreach my $k (kmerize($second_seq, 19))
	    {
		$num_kmers++;

		my ($valid_kmer, $kmer_count) = get_validity_and_kmer_count($k);
		if ($valid_kmer)
		{
		    $num_valid_kmers++;
		}

                # if kmer_count was -1 the kmer was unknown, therefore increase the counter and ignore that coverage for coverage calculation
		if ($kmer_count == -1)
		{
		    $num_unknown_kmers++;
		} else {
		    push(@kmer_counts, $kmer_count);
		}
	    }
	}

	my $percentage_valid_kmers = $num_valid_kmers/$num_kmers;
	my ($mean_coverage, $median_coverage) = calc_mean_median(\@kmer_counts);
	printf $outfh "%s percent_valid:%.5f mean_coverage:%.1f median_coverage:%.1f num_unknown_kmers_ignored_for_coverage: %d\n%s\n%s\n%s\n",
	$header, $percentage_valid_kmers, $mean_coverage, $median_coverage, $num_unknown_kmers, $seq, $header2, $qual;

	if ($options{paired})
	{
	    printf $outfh "%s percent_valid:%.5f mean_coverage:%.1f median_coverage:%.1f\n%s\n%s\n%s\n",
	    $second_header, $percentage_valid_kmers, $mean_coverage, $median_coverage, $second_seq, $second_header2, $second_qual;
	}

	if ( $filesize >= $next_update ) {
	    $progress->update($filesize);
	}

    }

    close(INPUT) || die "Unable to close input file '$inputfile': $!";
    if ($options{paired})
    {
	close($in2) || die "Unable to close input file '$inputfile2': $!";
    }

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

    unless (exists $kmer_cache->{$kmer})
    {
	unless (exists $missing_kmers{$kmer})
	{
	    warn "Error missing kmer: $kmer\n";
	    $missing_kmers{$kmer}++;
	}
	return( 0, -1 );
    }

    my ($lib300, $lib500, $lib800, $moleculo, $combined, $flag) = unpack("Q"x6, $kmer_cache->{$kmer});

    return ( ($flag==15) ? 1 : 0, $combined );
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

=item --kmerhash FILE

Indicate the location of kmer-hash file produced by the Storable module.

=back

=head1 SEE ALSO

TODO

=head1 AUTHOR

Frank Foerster (E<lt>frank.foerster@uni-wuerzburg.deE<gt>)

=head1 LICENCE

TODO

=head1 HISTORY

=cut
