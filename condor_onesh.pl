#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use File::Basename;

# By Chen Xilong
# Create Date: 11/2/2019 19:11
# Contact: chen_xilong@outlook.com

my $usage = "perl condor_onesh.pl <cpu nu> <mem> <your shell script>\n\n";
die $usage if @ARGV != 3;
my $cpu = shift @ARGV;
my $mem = shift @ARGV;
my $sh = shift @ARGV;
my $condor = <<"END_CONDOR";
Universe = vanilla
Executable = /bin/sh
Arguments = $sh
output = ./$sh.condor.out
error = ./$sh.condor.err
log = ./$sh.condor.log
JobLeaseDuration = 30
request_memory = $mem
request_cpus = $cpu
requirements = ( HAS_ASREML =?= False )
getenv = true
Queue
END_CONDOR

open my $ou, ">", "$sh.condor" or die;
print $ou $condor;


