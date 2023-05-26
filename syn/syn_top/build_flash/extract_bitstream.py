#!/usr/bin/env python3
# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

import argparse
import logging
import re
import sys

logging.basicConfig(level=0)
LOGGER= logging.getLogger(__name__)

def main(args):
    pof_map = args.map_file.read().decode('utf-8')

    m = re.search(r"Page_1\s+(0x[0-9a-fA-F]{8})\s+(0x[0-9a-fA-F]{8})", pof_map)
    if not m:
        LOGGER.error("Page_1 not found in map file")
        sys.exit(1)

    start = int(m.group(1), 0)
    bs_len = int(m.group(2), 0) - start + 1

    args.in_file.seek(start)
    bs = args.in_file.read(bs_len)
    args.out_file.write(bs)

if __name__ == '__main__':

    parser = argparse.ArgumentParser()

    parser.add_argument('map_file', type=argparse.FileType('rb'),
                        help='map_file of pof')
    parser.add_argument('in_file', type=argparse.FileType('rb'),
                        help='binary input file')
    parser.add_argument('out_file', type=argparse.FileType('wb'),
                        help='output file')

    args = parser.parse_args()
    main(args)
