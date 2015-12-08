#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Term::ProgressBar;

our $VERSION = '0.1';

my %kmer_cache = ();

my %options = ();

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

my $progress = Term::ProgressBar->new(
    {
        name  => 'Kmer Files: ',
        count => $filesize,
        ETA   => 'linear',
    }
);
$progress->max_update_rate(1);
my $next_update = 0;

my $pos = 0;
while (1) {
    foreach my $current (@order) {

        # read the next line for each buffer
        if ( $options{kmerlib}{$current}{filebuffer} eq "" ) {
            my $fh = $options{kmerlib}{$current}{filehandle};
            unless ( eof($fh) ) {
                $options{kmerlib}{$current}{filebuffer} = scalar <$fh>;
                $options{kmerlib}{$current}{fields} =
                  [ split( /\s+/, $options{kmerlib}{$current}{filebuffer} ) ];
                $pos += length( $options{kmerlib}{$current}{filebuffer} );
            }
        }
    }

    if ( $pos >= $next_update ) {
        $progress->update($pos);
    }

    # generate a list of current kmers
    my @kmers = map { $options{kmerlib}{$_}{fields}[0] } (@order);

    # sort the list to find the next kmer
    @kmers = sort @kmers;
    my @kmer_counts = ();

    # check if each dump contains the kmer and count
    foreach my $current (@order) {
        my $value = 0;    # assume no count
                          # check if the current line own the kmer
        if ( $options{kmerlib}{$current}{fields}[0] eq $kmers[0] ) {

            # get the value
            $value = int( $options{kmerlib}{$current}{fields}[1] );

            # empty the filebuffer
            $options{kmerlib}{$current}{filebuffer} = "";
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
        my $fh = $options{kmerlib}{$current}{filehandle};
        $num_eof++ if ( eof($fh) );
    }

    if ( $num_eof == @order ) {
        last;
    }
}

if ( $filesize >= $next_update ) {
    $progress->update($filesize);
}

# store a dump
my $file = $options{outputfile} . ".dump";

my $counter = 0;

$progress = Term::ProgressBar->new(
    {
        name  => 'Kmer Dump (' . $file . '): ',
        count => ( keys %kmer_cache ) + 0,
        ETA   => 'linear',
    }
);
$progress->max_update_rate(1);
$next_update = 0;

open( FH, ">", $file ) || die "Unable to open dump file '$file': $!";
print FH join( "\t", ( "#kmer", @order ) ), "\n";
while ( my ( $kmer, $array_ref ) = each %kmer_cache ) {
    $counter++;
    @$array_ref = map { ( defined $_ ) ? $_ : 0 } (@$array_ref);
    $kmer_cache{$kmer} = $array_ref;
    print FH join( "\t", ( $kmer, @$array_ref ) ), "\n";
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

