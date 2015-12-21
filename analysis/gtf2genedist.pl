#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use File::Basename;

use Verbose;
use Env;

our $VERSION = '1.00';
my %opt = ();

$opt{'gtf=s'} = \(my $opt_gtf = '');
$opt{'verbose=i'} = \(my $opt_verbose = 2);

my $V = Verbose->new(
        level => 1,
        report_level => $opt_verbose,
        line_width => 100,        
    );

$V->verbose("$0-$VERSION");

GetOptions(%opt) or pod2usage(1);

if(!$opt_gtf)
{
    $V->exit("Cannot find input files. Please specify lst file (--gtf)");
}

my $gtf_h = opt2handle("--lst",$opt_gtf,$V);

my $m_start = undef;
my $p_end = undef;
my $l_chr = undef;

while(<$gtf_h>)
{
    next if($_ =~ /^#/ || $_ =~ /^\s*$/);
    my @data = split(/\t+/,$_);
    if(!$l_chr)
    {
        $l_chr = $data[0];
    }
    elsif($l_chr ne $data[0])
    {
        $m_start = undef;
        $p_end = undef;
    }
    my $c_start = undef;
    my $c_end = undef;
    my $c_pos = undef;
    
    if($data[6] eq "+")
    {
        $c_pos = $data[2];
        $c_start = $data[3];
        $c_end = $data[4];
        if($p_end)
        {
            print $c_start - $p_end,"\n";
            $p_end = $c_end;
            next;
        }
        else
        {
            $p_end = $c_end;
            next;
        }
    }
    if($data[6] eq "-")
    {
        $c_pos = $data[2];
        $c_start = $data[3];
        $c_end = $data[4];
        if($m_start)
        {
            print $c_start - $m_start,"\n";
            $m_start = $c_end;
            next;
        }
        else
        {
            $p_end = $c_end;
            next;
        }
    }
}
close($lst_h);

sub opt2handle
{
    my ($k, $v, $V) = @_;
    my $h;
    return unless $v;     
    if(-f $v)
    {
        $V->verbose("$k: $v");
        open($h, '<', $v) or $V->exit("$!: $v");
    }
    return $h;      
}
