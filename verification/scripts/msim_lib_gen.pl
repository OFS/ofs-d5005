#!/usr/bin/env perl
# Copyright (C) 2022 Intel Corporation
# SPDX-License-Identifier: MIT

use strict;
my $transcript   = $ARGV[0] ;
my $libs;
open my $info, $transcript or die "Could not open $transcript: $!";

while( my $line = <$info>)  {   
    if($line =~ m/vsim -voptargs/)
    {
       $libs = $line;
       last;
     }   
}
close $info;

$libs =~ s/# vsim.*"//;
$libs =~ s/\-L/\n$&/g;
open(FH,">","temp.f");
print FH "$libs";    
close FH;

open(my $FHW,">","temp1.f");
open(my $FHR,"<","temp.f");
while(<$FHR>)
{
  next if /^\s*$/;
  if($_ =~ m/bpf\.bpf/)
   {
      $_ =~ s/bpf\.bpf//g;
      
      print $FHW "$_";
   }
  elsif($_ =~ m/qph_user_clk_iopll_reconfig\.qph_user_clk_iopll_reconfig/)
   {
      $_ =~ s/qph_user_clk_iopll_reconfig\.qph_user_clk_iopll_reconfig/-L qph_user_clk_iopll_reconfig\.qph_user_clk_iopll_reconfig/g;
      
      print $FHW "$_";
   }
  elsif($_ =~ m/remote_debug_jtag_only\.remote_debug_jtag_only/)
   {
      $_ =~ s/remote_debug_jtag_only\.remote_debug_jtag_only/-L remote_debug_jtag_only\.remote_debug_jtag_only/g;
      
      print $FHW "$_";
   } 
  elsif($_ =~ m/avst_pipeline_st_pipeline_stage_1\.avst_pipeline_st_pipeline_stage_1/)
   {
      $_ =~ s/avst_pipeline_st_pipeline_stage_1\.avst_pipeline_st_pipeline_stage_1/-L avst_pipeline_st_pipeline_stage_1\.avst_pipeline_st_pipeline_stage_1/g;
      
      print $FHW "$_";
   } 
  elsif($_ =~ m/sc_fifo_tx_sc_fifo\.sc_fifo_tx_sc_fifo/)
   {
      $_ =~ s/sc_fifo_tx_sc_fifo\.sc_fifo_tx_sc_fifo/-L sc_fifo_tx_sc_fifo\.sc_fifo_tx_sc_fifo/g;
      
      print $FHW "$_";
   } 
  else
  {
    print $FHW "$_";
  }  
}
close FHR;
close FHW;
system("rm -rf temp.f");

open(my $FHW,">","msim_lib.f");
open(my $FHR,"<","temp1.f");

while(<$FHR>)
{
    $_ =~ s/-L\ work_lib//g;
    $_ =~ s/-L /-L \$QLIB_DIR\//g;
    print $FHW "$_";
}
system("rm -rf temp1.f");
close FHR;
close FHW;
