#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Term::ProgressBar;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($INFO);

our $VERSION = '0.1';

my %kmer_cache = ();

my %options = ();

print INFO "Startet";

GetOptions(
    'o|output=s'   => \$options{outputfile},
    'k|kmerlib=s%' => \$options{kmerlibs}
) || die("Error in command line arguments\n");

my @order = sort ( keys %{ $options{kmerlibs} } );

my $filesize = 0;
foreach my $kmerlib_pos ( 0 .. @order - 1 ) {
    my $kmerlib = $order[$kmerlib_pos];

    $options{kmerlibs}{$kmerlib} = { filename => $options{kmerlibs}{$kmerlib} };
    $filesize += -s $options{kmerlibs}{$kmerlib}{filename};

    open( my $fh, "<", $options{kmerlibs}{$kmerlib}{filename} )
      || die "Unable to open file '"
      . $options{kmerlibs}{$kmerlib}{filename} . "': $!";
    $options{kmerlibs}{$kmerlib}{filehandle} = $fh;
    $options{kmerlibs}{$kmerlib}{filebuffer} = "";
}

my $pos = 0;
my $report_size = 1024*1024*100;
my $next_report = $report_size;
while (1) {
    foreach my $current (@order) {

        # read the next line for each buffer
        if ( $options{kmerlibs}{$current}{filebuffer} eq "" ) {
            my $fh = $options{kmerlibs}{$current}{filehandle};
            unless ( eof($fh) ) {
                $options{kmerlibs}{$current}{filebuffer} = scalar <$fh>;
                $options{kmerlibs}{$current}{fields} =
                  [ split( /\s+/, $options{kmerlibs}{$current}{filebuffer} ) ];
                $pos += length( $options{kmerlibs}{$current}{filebuffer} );
            }
        }
    }

    if ( $pos > $next_report ) { 
        print INFO sprintf("Finished %.0f MB (%.1f%%) and identified %d valid kmers...\n", $pos/(1024*1024), $pos/$filesize*100, (keys %kmer_cache)+0);
	$next_report+=$report_size;
    }

    # generate a list of current kmers
    my @kmers = grep { defined $_ && $_ ne "" } map { $options{kmerlibs}{$_}{fields}[0] } (@order);

    # sort the list to find the next kmer
    @kmers = sort @kmers;
    my @kmer_counts = ();

    # check if each dump contains the kmer and count
    foreach my $current (@order) {
        my $value = 0;    # assume no count
                          # check if the current line own the kmer
        if ( $options{kmerlibs}{$current}{fields}[0] eq $kmers[0] ) {

            # get the value
            $value = int( $options{kmerlibs}{$current}{fields}[1] );

            # empty the filebuffer
            $options{kmerlibs}{$current}{filebuffer} = "";
	    $options{kmerlibs}{$current}{fields} = ['',0];
        }
        push( @kmer_counts, $value ) if ( $value > 0 );
    }

    # does all libs contain the kmer?
    if ( @kmer_counts + 0 == @kmers + 0 ) {

        # sum the counts
        my $sum = 0;
        foreach (@kmer_counts) {
            $sum += $_;
        }

        # store the kmer and its count
        $kmer_cache{ $kmers[0] } = $sum;
    }

    # check if all files reached the eof
    my $num_eof = 0;
    foreach my $current (@order) {
        my $fh = $options{kmerlibs}{$current}{filehandle};
        $num_eof++ if ( eof($fh) );
    }

    if ( $num_eof == @order ) {
        last;
    }
}

# store a dump
my $file = $options{outputfile} . ".dump";

my $counter = 0;

my $progress = Term::ProgressBar->new(
    {
        name  => 'Kmer Dump (' . $file . '): ',
        count => ( keys %kmer_cache ) + 0,
        ETA   => 'linear',
    }
);
$progress->max_update_rate(30);
my $next_update = 0;

open( FH, ">", $file ) || die "Unable to open dump file '$file': $!";
print FH join( "\t", ( "#kmer", "valid_counts" ) ), "\n";
while ( my ( $kmer, $counts ) = each %kmer_cache ) {
    $counter++;
    print FH join( "\t", ( $kmer, $counts ) ), "\n";
    if ( $counter > $next_update ) {
        $next_update = $progress->update($counter);
    }
}
close(FH) || die "Unable to close dump file '$file': $!";

if ( ( keys %kmer_cache ) + 0 >= $next_update ) {
    $progress->update( ( keys %kmer_cache ) + 0 );
}

# store the hash in the output file
use Storable;
Storable::nstore( \%kmer_cache, $options{outputfile} ) || die;

__END__

