#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use File::Basename;

# By Chen Xilong
# Create Date: 11/2/2019 19:11
# Contact: chen_xilong@outlook.com
my $usage = "perl condor_psh.pl <cpu nu> <mem>\n\n";
die $usage if @ARGV != 2;

my @sh  = glob("*.sh");
my $cpu = shift @ARGV;
my $mem = shift @ARGV;

open my $ou, ">", "00psh.condor" or die;
my $condor = <<"END_CONDOR";
Universe = vanilla
Executable = /bin/sh
output = ./00psh.condor.out
error = ./00psh.condor.err
log = ./00psh.condor.log
JobLeaseDuration = 30
request_memory = $mem
request_cpus = $cpu
requirements = ( HAS_ASREML =?= False )
getenv = true
END_CONDOR
print $ou $condor;

for my $sh (@sh) {
    print $ou "Arguments = $sh\n";
    print $ou "Queue\n";

}

