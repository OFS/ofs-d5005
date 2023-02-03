#!/usr/bin/env python
# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

import sys
import os
import re
import fileinput
import argparse

ddr_core_clocks = [
    'mem|mem_bank[0].emif_ddr4_inst|emif_s10_0_core_usr_clk',
    'mem|mem_bank[1].emif_ddr4_inst|emif_s10_0_core_usr_clk',
    'mem|mem_bank[2].emif_ddr4_inst|emif_s10_0_core_usr_clk',
    'mem|mem_bank[3].emif_ddr4_inst|emif_s10_0_core_usr_clk',
]


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("--sdc", required=True,
                        default="", help="input SDC file")

    return parser.parse_args()


def fix_hold_clock_uncertainty(sdc, core_clocks):
    reg_exp = r'set_clock_uncertainty -.*_from \[get_clocks {(.*)}\] -.*_to \[get_clocks {(.*)}\].*-enable_same_physical_edge'
    sdc_re = re.compile(reg_exp)
    new_sdc = sdc + '.new'

    sdc_in = open(sdc, 'r')
    sdc_out = open(new_sdc, 'w')
    for line in sdc_in:
        if 'enable_same_physical_edge' in line:
            m = sdc_re.match(line)
            if (m.group(1) == m.group(2)) and (m.group(1) in core_clocks):
                line = line.replace('-enable_same_physical_edge', '')
        sdc_out.write(line)

    sdc_in.close()
    sdc_out.close()
    os.rename(new_sdc, sdc)


def fix_get_combs(sdc):
    new_sdc = sdc + '.new'
    sdc_in = open(sdc, 'r')
    sdc_out = open(new_sdc, 'w')
    for line in sdc_in:
        if '[get_combs' in line:
            cnt = 0
            for i in range(line.find("[get_combs")+1, len(line)):
                if line[i] == "[":
                    cnt += 1
                if line[i] == "]":
                    if cnt == 0:
                        line = line[:i]+line[i+1:]
                        break
                    else:
                        cnt -= 1
                        continue
            line = line.replace("[get_combs", "")
        sdc_out.write(line)
    sdc_in.close()
    sdc_out.close()
    os.rename(new_sdc, sdc)


# During a PR compilation, Quartus 20.2 complains first that SYS_REFCLK is
# already defined and then it complains that it is not defined at all,
# leading to failure. Appending -add to a new definition of the clock solves
# the problem.
def fix_top_clock_pins(sdc):
    reg_exp = r'create_clock -name {[A-Z]+_REFCLK}'
    sdc_re = re.compile(reg_exp)
    new_sdc = sdc + '.new'

    sdc_in = open(sdc, 'r')
    sdc_out = open(new_sdc, 'w')
    for line in sdc_in:
        if sdc_re.match(line):
            line = line.rstrip() + ' -add\n'
        sdc_out.write(line)

    sdc_in.close()
    sdc_out.close()
    os.rename(new_sdc, sdc)


def main(argv):
    args = parse_arguments()
    fix_hold_clock_uncertainty(args.sdc, ddr_core_clocks)
    fix_get_combs(args.sdc)
    fix_top_clock_pins(args.sdc)


if __name__ == "__main__":
    main(sys.argv[1:])
