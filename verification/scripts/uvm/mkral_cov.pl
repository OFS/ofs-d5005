#!/usr/bin/perl -w
# Copyright (C) 2022 Intel Corporation
# SPDX-License-Identifier: MIT

my $f1 = shift || die "Usage: mkral.pl <XLS file name w/o extention> <register block name> <[block size] | default 8> \n";
my $f2 = shift;
my $f3 = shift || "8";

die "Usage: mkral.pl <XLS file name w/o extention> <register block name> <[block size] | default 8> \n" unless (-e "$f1.xls");

print "Processing - $f1 into ral_$f2.sv RAL file \n";


#system("xls2xml.pl $f1.xls $f2; \
#        ralgen -uvm -ipxact2ralf $f1.xml -t $f2; \
#        perl -p -i.bak -e \"s/system/block/\" $f1.ralf;
#        perl -p -i.bak -e \"s/^    bytes 4/    bytes $f3/\" $f1.ralf;
#        perl -p -i.bak -e \"s/^.*REMOVEIT.*//\" $f1.ralf;
#        perl -p -i.bak -e \"s/^}//\" $f1.ralf; \
#        sed "/register/ s/$/\n\t cover +f/" src_$f1.ralf > field_cov_$f1.ralf; \
#        ralgen -uvm  field_cov_$f1.ralf -t $f2 -c f ;" );

system("xls2xml.pl $f1.xls $f2; \
        ralgen -uvm -ipxact2ralf $f1.xml -t $f2; \
        perl -p -i.bak -e \"s/system/block/\" $f1.ralf;
        perl -p -i.bak -e \"s/^    bytes 4/    bytes $f3/\" $f1.ralf;
        perl -p -i.bak -e \"s/^.*REMOVEIT.*//\" $f1.ralf;
        perl -p -i.bak -e \"s/^}//\" $f1.ralf;");
 
###my $ralf_file = "$f1.ralf";
###my $ralf_cov = "field_cov_$f2.ralf";
###system ('sed  "/register/ s/$/\n\t cover +f/" $1".ralf > ne_') ; 

#system ("ralgen -uvm  field_cov_$f1.ralf -t $f2 -c f ;" );
#system ("ralgen -uvm  $ralf_cov -t $f2 -c f ;" );

#system ( 'sed "/register/ s/$/\n\t cover +f/" HSSI_SS_CSR.ralf > field_cov_$f1.ralf ');
###$name_org ="ral_${f2}.sv";
###$name_cov = "ral_${f2}_cov.sv";
###system (" mv ${name_org} ${name_cov}");

