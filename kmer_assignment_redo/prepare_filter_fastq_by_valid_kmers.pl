#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Term::ProgressBar;

our $VERSION = '0.1';

my %options = ();

GetOptions(
    'o|output=s'  => \$options{outputfile},
    'k|kmerlib=s%' => \$options{kmerlibs}
    ) || die ("Error in command line arguments\n");

my %kmer_cache = ();

# same for the kmerlib files
foreach my $kmerlib (keys %{$options{kmerlibs}})
{
    $options{kmerlibs}{$kmerlib} = [ map { { filename => $_ } } split(',', $options{kmerlibs}{$kmerlib}) ];

    # read the content and create the hash
    foreach my $file (@{$options{kmerlibs}{$kmerlib}})
    {
	my $filesize = -s $file->{filename};
	my $progress = Term::ProgressBar->new(
	{
	    name  => 'Kmer File ('.$file->{filename}.'): ',
	    count => $filesize,
	    ETA   => 'linear',
	}
	);
	$progress->max_update_rate(1);
	my $next_update = 0;

	open(FH, "<", $file->{filename}) || die "Unable to open file '$file->{filename}': $!";

	while (<FH>)
	{

	    if ( tell(FH) > $next_update ) {
		$next_update = $progress->update( tell(FH) );
	    }
	    
	    chomp;
	    my @fields = split(/\t/, $_);

	    $kmer_cache{$fields[0]}{$kmerlib} += $fields[1];
	}
	
	close(FH) || die "Unable to close file '$file->{filename}': $!";

	if ( $filesize >= $next_update ) {
	    $progress->update($filesize);
	}

	print STDERR "\n";

    }
}

# store the hash in the output file
use Storable;
Storable::nstore(\%kmer_cache, $options{outputfile}) || die;

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
