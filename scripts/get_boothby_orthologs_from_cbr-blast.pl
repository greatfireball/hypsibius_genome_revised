#!/usr/bin/env perl
use strict;
use warnings;

my $hgt_flagged_file = $ARGV[0];
my $crb              = $ARGV[1];

my %hgt_flagged = ();
my @dat = ();

my $threshold = 99;

open(FH, "<", $hgt_flagged_file) || die;
while(<FH>)
{
    chomp;
    $hgt_flagged{$_}++;
}
close(FH) || die;

open(FH, "<", $crb) || die;
while(<FH>)
{
    chomp;
    push(@dat, [split /\t/, $_]);
}
close(FH) || die;

# get the number of Genes:
my @passed_threshold = grep {$_->[2] >= $threshold} (@dat);

my %own_genes     = ();
my %boothby_genes = ();

my %boothby_hgt   = ();

foreach (@passed_threshold)
{
    $own_genes{$_->[0]}++;
    push(@{$boothby_genes{$_->[1]}}, $_->[0]);

    my $id = $_->[1];
    $id=~s/-mRNA.*//g;

    if (exists $hgt_flagged{$id})
    {
	$boothby_hgt{$_->[1]}++;
    }
}

printf "Number of own genes: %d corresponding to %d Boothby genes\n", (keys %own_genes)+0, (keys %boothby_genes)+0;

# expand the boothby genes to our names:
my %own_hgt = ();
foreach my $boothby_id (keys %boothby_hgt)
{
    foreach (@{$boothby_genes{$boothby_id}})
    {
	$own_hgt{$_}++;
    }
}

printf "Number of boothby genes marked HGT: %d corresponding to %d of our genes\n", (keys %boothby_hgt)+0, (keys %own_hgt)+0;


