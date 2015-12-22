use strict;
use warnings;

my %dat = (
    '300_unfiltered' => {},
    '500_unfiltered' => {},
    '800_unfiltered' => {},
    'mol_unfiltered' => {},
    'all_unfiltered' => {},
    '300_filtered'   => {},
    '500_filtered'   => {},
    '800_filtered'   => {},
    'mol_filtered'   => {},
    'all_filtered'   => {},
);

while (<>) {
    next if (/^#/);
    chomp;

    # split the line
    my ( $kmer, $lib300, $lib500, $lib800, $libmol, $flag ) = split( /\t/, $_ );

    # generate the unfiltered histos
    $dat{'300_unfiltered'}{$lib300}++;
    $dat{'500_unfiltered'}{$lib500}++;
    $dat{'800_unfiltered'}{$lib800}++;
    $dat{'mol_unfiltered'}{$libmol}++;
    $dat{'all_unfiltered'}{ $lib300 + $lib500 + $lib800 + $libmol }++;

    next unless ( $flag == 15 );

    # generate the unfiltered histos
    $dat{'300_filtered'}{$lib300}++;
    $dat{'500_filtered'}{$lib500}++;
    $dat{'800_filtered'}{$lib800}++;
    $dat{'mol_filtered'}{$libmol}++;
    $dat{'all_filtered'}{ $lib300 + $lib500 + $lib800 + $libmol }++;
}

foreach my $file ( keys %dat ) {
    print STDERR "Writing file '$file'...";
    open( FH, ">", $file ) || die "$!";
    foreach my $kmer_cov ( sort { $a <=> $b } ( keys %{ $dat{$file} } ) ) {
        print FH join( "\t", ( $kmer_cov, $dat{$file}{$kmer_cov} ) ), "\n";
    }
    close(FH) || die "$!";
}
