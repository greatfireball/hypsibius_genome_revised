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

