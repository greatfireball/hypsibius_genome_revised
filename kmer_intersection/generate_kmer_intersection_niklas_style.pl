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

my %data = ();

for my $file (@order)
{
    open( my $fh, "<", $files{$file} )
      || die "Unable to open file '" . $files{$file} . "': $!";

    while (<$fh>)
    {
	chomp;
	unless (/^([AGCT]+)\t(\d+)/)
	{
	    die "Something is wrong for file: '$files{$file}' line $. : '$_'";
	}

	my ($kmer, $val) = ($1, $2);

	$data{$kmer}{$file} = $val;
    }

    close( $fh )
      || die "Unable to close file '" . $files{$file} . "': $!";

}

print STDERR "Import of ", (keys %data)+0, " kmers finished\n";

# print a header
print join( "\t", ( "#kmer", @order, "flag" ) ), "\n";

my %flag_hash = ();

foreach my $kmer (keys %data)
{

    my @values = ();
    my $flag = 0;

    foreach my $file (@order)
    {
	my $val = 0;
	if (exists $data{$kmer}{$file})
	{
	    $val = $data{$kmer}{$file};
	    $flag |= $flags{$file};
	}
	push(@values, $val);
    }

    $flag_hash{$flag}++;

    print join("\t", ($kmer, @values, $flag)),"\n";
}

print STDERR "Flags generated:\n";
foreach my $flag (sort {$a <=> $b} (keys %flag_hash))
{
    print STDERR $flag,"\t",$flag_hash{$flag},"\n";
}
