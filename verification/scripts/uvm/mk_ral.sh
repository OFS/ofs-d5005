#!/bin/bash
# Copyright (C) 2022 Intel Corporation
# SPDX-License-Identifier: MIT

mkral_cov.pl $1  $2;
sed '/field/ s/$/\n\t cover +f/' "$1.ralf" > field_cov_"$1".ralf 
sed -i.bak -e '/field Reserved/{n;N;d}' field_cov_"$1".ralf
sed -i.bak -e '/field Rsvd/{n;N;d}' field_cov_"$1".ralf
sed -i.bak -e '/field DfhRsvd0/{n;N;d}' field_cov_"$1".ralf
sed -i.bak -e '/field DfhRsvd1/{n;N;d}' field_cov_"$1".ralf
sed -i.bak -e '/field Ctrl_rsvd/{n;N;d}' field_cov_"$1".ralf
sed -i.bak -e '/field Status_rsvd/{n;N;d}' field_cov_"$1".ralf
ralgen -uvm  field_cov_"$1".ralf -t "$2" -c f 
mv  ral_"$2".sv  ral_"$2"_cov.sv
mkral.pl $1 $2
tcsh

