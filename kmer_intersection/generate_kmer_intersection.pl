#!/usr/bin/env perl

use strict;
use warnings;

my %files = ();

$files{300} = shift;
$files{500} = shift;
$files{800} = shift;
$files{moleculo} = shift;

foreach my $file (keys %files)
{
    $files{$file}{name} = $files{$file};
    open($files{$file}{fh}, "<", $files{$file}{name}) || die "Unable to open file '".$files{$file}{name}."': $!";
}


foreach my $file (keys %files)
{
    close($files{$file}{fh}) || die "Unable to close file '".$files{$file}{name}."': $!";
}

