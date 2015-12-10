#!/usr/bin/env perl

use strict;
use warnings;

my %files = ();

$files{300}      = shift;
$files{500}      = shift;
$files{800}      = shift;
$files{moleculo} = shift;

my @order = qw(300 500 800 moleculo);
my %flags = ();
for ( my $i = 0 ; $i < @order ; $i++ ) {
    $flags{ $order[$i] } = 2**$i;
}

foreach my $file (@order) {
    my $name = $files{$file};
    $files{$file} = { name => $name };
    $files{$file}{line} = undef;
    open( my $fh, "<", $files{$file}{name} )
      || die "Unable to open file '" . $files{$file}{name} . "': $!";
    $files{$file}{fh} = $fh;
}

# print a header
print join( "\t", ( "#kmer", @order, "flag" ) ), "\n";

while ( grep { !eof( $files{$_}{fh} ) } (@order) ) {

    # which file I have to read?
    foreach my $file (@order) {

	my $fh = $files{$file}{fh};
	# read the next line from the file if not eof and the line value is undef
        unless ( defined $files{$file}{line} && eof( $fh ) ) {
            $files{$file}{line} = <$fh>;

	    unless (defined $files{$file}{line})
	    {
		$files{$file}{line} = "";
		$files{$file}{kmer} = undef;
	    } else {
		chomp( $files{$file}{line} );
		( $files{$file}{kmer}, $files{$file}{count} ) =
		    split( /\t/, $files{$file}{line} );
	    }
        }
    }

    # find the next (alphabetically first) kmer
    my ($next_kmer) = sort map { $files{$_}{kmer} } grep {defined $files{$_}{kmer}} (@order);

    # extract the information from each input file
    my @values = ();
    my $flag   = 0;
    foreach my $file (@order) {
        my $val = 0;
        if ( defined $files{$file}{kmer} && $files{$file}{kmer} eq $next_kmer ) {
            $val = $files{$file}{count};
            $files{$file}{line} = undef;
	    $files{$file}{kmer} = undef;
            $flag = $flag + $flags{$file};
        }
        push( @values, $val );
    }

    print join( "\t", ( $next_kmer, @values, $flag ) ), "\n";

}

foreach my $file (@order) {
    close( $files{$file}{fh} )
      || die "Unable to close file '" . $files{$file}{name} . "': $!";
}

