#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use File::Basename;

# By Chen Xilong
# Create Date: 2/24/2020 11:06
# Contact: chen_xilong@outlook.com

# input file
my @files = @ARGV;
die "usage: perl $0 <your01.fa> <your02.fa> <your02.fa>\n" if @files < 2;

`if [ -d "./blast_tmp" ]; then rm -rf ./blast_tmp; fi; mkdir ./blast_tmp`;
open my $ou, ">", "./blast_tmp/merge.fa" or die;

# merge three file and change the name.
# build a hash of seq and length

print
    "Give a mark name for every fasta file.\nRemove sequence length short than 120bp. Then merge the left to one big fasta file.\n";
my %l_hash;
for ( 0 .. $#files ) {
    my $f = $files[$_];
    my $m = "f$_";
    print "$f => $m\n";
    my $m2 = $m . "_";
    open my $fh, "<", "$f" or die;
    open my $out, ">", "./blast_tmp/m.$f" or die;
    $/ = ">";
    <$fh>;

    while (<$fh>) {
        chomp;
        my ( $gene, $seq ) = split /\n/, $_, 2;
        my $new_name = $m2 . $gene;
        my $new_seq  = $seq;
        $new_seq =~ s/\n//g;
        my $l = length $seq;
        next if ( $l < 120 ); # length limit
        print $out ">$new_name\n$seq";
        print $ou ">$new_name\n$seq";
        my ($n) = split / /, $new_name;
        $l_hash{$n} = $l;
    }
    close $fh;
    $/ = "\n";
}

# print Dumper \%l_hash;


print "Build the blast index(database) of merged fasta file\n";
`makeblastdb -in ./blast_tmp/merge.fa -parse_seqids -hash_index -dbtype nucl`;

print "Start to blast every file to the database.\n";
for my $f (@files) {
    `blastn -task blastn -query ./blast_tmp/m.$f -db ./blast_tmp/merge.fa -out ./blast_tmp/re.$f -outfmt "6 std qcovs" -evalue 1e-5 -num_threads 10 && echo "blastn $f done!!"`; # -num_threads 10 the number of cpu
}

print "Find the redundant sequences.\n";
my %rm_id;
for my $f (@files) {
    my $ref = "./blast_tmp/re.$f";
    open my $fh, "<", "$ref" or die;
    while (<$fh>) {
        chomp;
        my @array = split /\t/, $_;
        $array[0] =~ /^(f\d)/;
        my $ff0 = $1;
        $array[1] =~ /^(f\d)/;
        my $ff1 = $1;
        next if ( $ff0 eq $ff1 );
        if ( $array[2] > 80 and $array[12] > 80 ) { # here is the identity rate and coverage rate cut-off
            my @a;
            if ( $l_hash{ $array[0] } < $l_hash{ $array[1] } ) {
                @a = ( $array[1], $array[0] );
            }
            else {
                @a = ( $array[0], $array[1] );
            }
            $rm_id{ $a[1] } = 1;
        }
    }
}

# print Dumper \%rm_id;

print "Output the non-redundant.fa.\n";
open my $in,     "<", "./blast_tmp/merge.fa" or die;
open my $out,    ">", "./non-redundant.fa"   or die;
open my $rm_out, ">", "./removed.fa"         or die;
$/ = ">";
<$in>;
while (<$in>) {
    chomp;
    my ( $gene, $seq ) = split /\n/, $_, 2;
    my ($n) = split / /, $gene;
    # print "$gene\n";
    if ( not exists $rm_id{$n} ) {
        print $out ">$gene\n$seq";
    }
    else {
        print $rm_out ">$gene\n$seq";
    }
}
close $in;
$/ = "\n";

print "Done! you can remove blast-tmp to save space.\n"
