#!/usr/bin/env perl

use strict;
use warnings;

my %mapping = (
    "A" => 0,
    "C" => 1,
    "G" => 2,
    "T" => 3,
    );

while (<>)
{
    chomp;

    my @fields = split "\t", $_;

    my $output = pack ("aaaaa", maptotwobits($fields[0])). pack("llll", @fields[1..4]);

    print $output;
}

sub maptotwobits
{
    my ($str) = @_;

    my $out = 0;

    foreach (split//, $str)
    {
	$out = $out << 2;
	$out = $out + $mapping{$_};
    }

    return $out;
}
