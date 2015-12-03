#!/usr/bin/env perl

use strict;
use warnings;

use Term::ProgressBar;

my $file = shift;

my $filesize = -s $file;

my %dataset = ();

my $progress = Term::ProgressBar->new(
    {
        name  => 'Inputfile',
        count => $filesize,
        ETA   => 'linear',
    }
);
$progress->max_update_rate(1);
my $next_update = 0;

open( FH, "<", $file ) || die "Unable to open file '$file': $!";

while (<FH>) {
    if ( tell(FH) > $next_update ) {
        $next_update = $progress->update( tell(FH) );
    }

    my $tag = substr( $_, 0, 2 );

    $dataset{$tag} .= $_;
}

if ( $filesize >= $next_update ) {
    $progress->update($filesize);
}

close(FH) || die "Unable to close file '$file': $!";

foreach my $tag ( keys %dataset ) {
    my $file_tagged = $file . $tag;
    open( FH, ">", $file_tagged )
      || die "Unable to open file '$file_tagged': $!";
    print FH $dataset{$tag};
    close(FH) || die "Unable to close file '$file_tagged': $!";
}
