#!/usr/bin/env perl

use strict;
use warnings;

use Term::ProgressBar;

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
    my $filesize = -s $files{$file};

    my $progress = Term::ProgressBar->new(
	{
	    name  => 'File '.$file,
	    count => $filesize,
	    ETA   => 'linear',
	}
	);
    $progress->max_update_rate(1);
    my $next_update = 0;

    open( my $fh, "<", $files{$file} )
      || die "Unable to open file '" . $files{$file} . "': $!";

    while (<$fh>)
    {
	if ( tell($fh) > $next_update ) {
	    $next_update = $progress->update( tell($fh) );
	}

	chomp;
	unless (/^([AGCT]+)\t(\d+)/)
	{
	    die "Something is wrong for file: '$files{$file}' line $. : '$_'";
	}

	my ($kmer, $val) = ($1, $2);

	$data{$kmer}{$file} = $val;
    }


    if ( $filesize >= $next_update ) {
	$progress->update($filesize);
    }
    print STDERR "\n";

    close( $fh )
      || die "Unable to close file '" . $files{$file} . "': $!";

}

print STDERR "Import of ", (keys %data)+0, " kmers finished\n";

# print a header
print join( "\t", ( "#kmer", @order, "flag" ) ), "\n";

my %flag_hash = ();

my $hashsize = (keys %data)+0;

my $progress = Term::ProgressBar->new(
    {
	name  => 'Output',
	count => $hashsize,
	ETA   => 'linear',
    }
    );
$progress->max_update_rate(1);
my $next_update = 0;

my $hashcount = 0;

foreach my $kmer (keys %data)
{
    $hashcount++;

    if ( $hashcount > $next_update ) {
        $next_update = $progress->update($hashcount );
    }

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

if ( $hashsize >= $next_update ) {
    $progress->update($hashsize);
}

print STDERR "\nFlags generated:\n";
foreach my $flag (sort {$a <=> $b} (keys %flag_hash))
{
    print STDERR $flag,"\t",$flag_hash{$flag},"\n";
}
