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

What is the input file. Any file format supported by Bioperl can be
used. A value for that option is required.

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

Default value is 100

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
    'w|step-width=s'          => \( $config{step_width} = 100 ),
    'm|min-length=s'            => \( $config{min_length} = 2500 ),
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

unless ( $config{inputfile} ) {
    warn "\n\nError: An input is required to run the script!\n\n\n";
    pod2usage(1);
}

eval { require Bio::SeqIO; }
  || die "The module 'Bio::SeqIO' is required. Please install it.\n";

# program starts here

# check the sliding window size:
# Does it contain a suffix
if ( $config{size_sw} =~ s/([Kk]|[Mm]|[Gg])($|b[p]?)// ) {
    my $suffix = uc($1);

    # the parameter now only contains digits
    unless ( $config{size_sw} =~ /^\s*\d+\s*$/ ) {
        die
"The parameter for the window size seems to be wrong! Only integers with a size suffix (k|m|g(bp)) are allowed.\n";
    }

    # what is the suffix
    if ( $suffix eq "K" ) {
        $config{size_sw} *= 1000;
    }
    elsif ( $suffix eq "M" ) {
        $config{size_sw} *= 1000000;
    }
    elsif ( $suffix eq "G" ) {
        $config{size_sw} *= 1000000000;
    }
    else {
        die "Should not happen!\n";
    }
}

# open the input file

my $seqio_object = Bio::SeqIO->new( -file => $config{inputfile} );

# and go through all sequences
while ( my $seq_obj = $seqio_object->next_seq ) {

    # skip to next sequence if the length is less then the required
    # length
    if ( $seq_obj->length() <= $config{min_length} ) {
        warn sprintf
"Skipping sequence '%s' due to length constrain (require a length of %s but found %s)\n",
          $seq_obj->id(), $config{min_length}, $seq_obj->length();
	next;
    }

    # calculate the GC content for each sliding window
    my $seq = $seq_obj->seq();

    my @gc = sw_gc( \$seq, $config{size_sw}, $config{step_width} );

    print join( "\t", ( $seq_obj->id(), join( ",", @gc ) ) ), "\n";
}

sub sw_gc {

    # parameters are
    # 1) reference to the sequence string
    # 2) sliding window size
    # 3) step size for the width

    # output is an array of gc values

    my ( $ref_seq, $sw_size, $step_size ) = @_;

    my @gc = ();

    for (
        my $i = 0 ;
        $i < ( length($$ref_seq) - $step_size ) ;
        $i += $step_size
      )
    {
        push( @gc, get_gc( \substr( $$ref_seq, $i, $sw_size ) ) );
    }

    return @gc;
}

sub get_gc {

    # parameter is a reference to a sequence string

    # output is a single value for the GC content

    my ($ref_seq) = @_;

    my $gc = undef;

    # make the string upper case
    my $seq = uc($$ref_seq);

    # count the number of Gs and Cs inside the string
    $gc = $seq =~ tr/GC/GC/;

    return ( $gc / length($seq) );

}

__END__

=pod

=cut
