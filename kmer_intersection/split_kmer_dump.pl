#!/usr/bin/env perl

use strict;
use warnings;

my $file = shift;

my %dataset = ();

open(FH, "<", $file) || die "Unable to open file '$file': $!";

while (<FH>)
{
    my $tag = substr($_, 0, 2);

    $dataset{$tag} .= $_;
}

close(FH) || die "Unable to close file '$file': $!";

foreach my $tag (keys %dataset)
{
    my $file_tagged = $file.$tag;
    open(FH, ">", $file_tagged) || die "Unable to open file '$file_tagged': $!";
    print FH $dataset{$tag};
    close(FH) || die "Unable to close file '$file_tagged': $!";
}
