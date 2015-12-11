#!/usr/bin/env perl

use strict;
use warnings;

my $VERSION = 1.00000;

use Pod::Usage;

use Getopt::Long;

my %config = ();

=pod

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 OPTIONS

=over 4

=item -i|--input

What is the input file. Any file format supported by Bioperl can be used.

=item -o|--output

What is the name of the output file. This is a tab separated file
containing the contig name and all gc values for each sliding
window. A single dash '-' can be used to define output to standard
out.

Default = - (output to stdout).

=item -s|--sliding-window-size

This number indicates the size of the sliding window used for the GC
content calculation. Allowed suffixes are k,m, and g followed by an
optional b or bp to indicate kilo, mega, or giga basepairs.

Default value is 1000 bp.

=item -w|--step-width

This integer number determines the step size for the sliding
window. It is also possible to provide a percentage value or a
floating point number. In those cases the meaning is relative to the
sliding window size.

Default value is 10% of the sliding window size.

=item -m|--min-length

Contigs with a sequencing length below that threshold will be ignored
for the GC calculations.

Default value is 2500 bp

=item -h|--help

Print the help information.

=item --man

Prints a detailed help information.

=item -v|--version

Prints a version information.

=cut

GetOptions(
    'i|input=s'               => \$config{inputfile},
    'o|output=s'              => \( $config{outputfile} = '-' ),
    's|sliding-window-size=s' => \( $config{size_sw} = 1000 ),
    'w|step-width=s'          => \( $config{step_width} = '10%' ),
    'm|min-length'            => \( $config{min_length} = 2500 ),
    'h|help'                  => \( $config{help} = 0 ),
    'man'                     => \( $config{man} = 0 ),
    'v|version'               => \( $config{version} = 0 )
) || pod2usage(2);

pod2usage(1) if ( $config{help} );
pod2usage( -exitval => 0, -verbose => 2 ) if ( $config{man} );

if ( $config{version} ) {
    print $VERSION;
    exit(0);
}

# program starts here

__END__

=pod

=cut
