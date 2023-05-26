#!/usr/bin/perl -w
# Copyright 2021 Intel Corporation
# SPDX-License-Identifier: MIT

die "you gonna crash some other library $!\n" unless $ENV{'PWD'} =~ $ENV{'WORKDIR'};
my %unihash;
my @unifile;
my @tmpfile;
my $ip_lst_file = "$ENV{'WORKDIR'}/sim/stratix10/s10dx_dk/bbs/scripts/$ARGV[0]";
system "mkdir -p $ENV{'WORKDIR'}/sim/stratix10/s10dx_dk/bbs/ip_libraries";
system "touch $ENV{'WORKDIR'}/sim/stratix10/s10dx_dk/bbs/ip_libraries/synopsys_sim.setup";
my $syn_setup_file = "$ENV{'WORKDIR'}/sim/stratix10/s10dx_dk/bbs/ip_libraries/synopsys_sim.setup";
my @ip_lst;
my $synfile = "synfile";
#open SRCFILE, "<ip_list.f" or die "Can\'t open $runlog_file -> $!\n";
open SRCFILE, "<$ip_lst_file" or die "Can\'t open $ip_lst_file -> $!\n";
open OUTPUT, ">$syn_setup_file" or die "Can\'t open $syn_setup_file -> $!\n";

while (<SRCFILE>){
    next if m/^\s*$/;
    next if m/^\s*#/;
    chomp;
#    print $_, "\n";
    my $lnn = "$ENV{'WORKDIR'}/$_/sim/synopsys/vcsmx/synopsys_sim.setup";
    open SETSYN, "<$lnn"  || die "Can\'t open $lnn $!\n";
    @tmpfile = <SETSYN>;
    push (@ip_lst,@tmpfile);
   close SETSYN;  
    }
    close SRCFILE;
    foreach $ip (@ip_lst){
    next if $ip =~/^\s*$/;
    next unless $ip =~/:/;
    chomp $ip;
    my $lnn = $ip;
    my ($key,$val) = split (/:/,$lnn);
    push (@unifile,$lnn) unless defined $unihash{$key};
    $unihash{$key} = $val ;
}
foreach $line (@unifile){
    print OUTPUT $line,"\n";
}
close OUTPUT;

