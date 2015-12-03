#!/usr/bin/env perl

use strict;
use warnings;

my $file = shift;

my %dataset = ();

open(FH, "<", $file) || die "Unable to open file '$file': $!";

close(FH) || die "Unable to close file '$file': $!";
