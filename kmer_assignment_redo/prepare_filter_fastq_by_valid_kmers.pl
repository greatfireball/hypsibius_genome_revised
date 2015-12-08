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
# set the number of elements to 400 Mio
keys %kmer_cache = 400000000;

# same for the kmerlib files
# do we have an all file?
if (exists $options{kmerlibs}{all})
{
    my $file = $options{kmerlibs}{all};
    
    delete $options{kmerlibs}{all};
    
    my $filesize = -s $file;
    my $progress = Term::ProgressBar->new(
	{
	    name  => 'Kmer File ('.$file.'): ',
	    count => $filesize,
	    ETA   => 'linear',
	}
	);
    $progress->max_update_rate(1);
    my $next_update = 0;
    
    open(FH, "<", $file) || die "Unable to open file '$file': $!";
    
    my @kmers = ();
    
    while (<FH>)
    {
	
	if ( tell(FH) > $next_update ) {
	    $next_update = $progress->update( tell(FH) );
	}
	
	push(@kmers, substr($_, 0, 19));
    }
    
    close(FH) || die "Unable to close file '$file->{filename}': $!";
    
    if ( $filesize >= $next_update ) {
	$progress->update($filesize);
    }

    my @store = keys %{$options{kmerlibs}};

    %kmer_cache = map { $_ => [0, 0, 0, 0] } (@kmers);

    print STDERR "\n";

}

my @order = sort (keys %{$options{kmerlibs}});
foreach my $kmerlib_pos (0..@order-1)
{
    my $kmerlib = $order[$kmerlib_pos];
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
	    
	    my $kmer = substr($_, 0, 19);
	    my $count = substr($_, 19);

	    $kmer_cache{$kmer}[$kmerlib_pos] += $count;
	}
	
	close(FH) || die "Unable to close file '$file->{filename}': $!";

	if ( $filesize >= $next_update ) {
	    $progress->update($filesize);
	}

	print STDERR "\n";

    }

    $kmerlib_pos++;
}

# store a dump
my $file = $options{outputfile}.".dump";

my $counter = 0;

my $progress = Term::ProgressBar->new(
    {
	name  => 'Kmer Dump ('.$file.'): ',
	count => (keys %kmer_cache)+0,
	ETA   => 'linear',
    }
    );
$progress->max_update_rate(1);
my $next_update = 0;

open(FH, ">", $file) || die "Unable to open dump file '$file': $!";
print FH join("\t", ("#kmer", @order)),"\n";
while (my ($kmer, $array_ref) = each %kmer_cache)
{
    $counter++;
    @$array_ref = map { (defined $_) ? $_ : 0 } (@$array_ref);
    $kmer_cache{$kmer} = $array_ref;
    print FH join("\t", ($kmer, @$array_ref)),"\n";
    if ( $counter > $next_update ) {
	$next_update = $progress->update( $counter );
    }
}
close(FH) || die "Unable to close dump file '$file': $!"; 

if ( (keys %kmer_cache)+0 >= $next_update ) {
    $progress->update((keys %kmer_cache)+0);
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
