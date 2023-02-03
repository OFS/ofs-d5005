# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

define_project d5005

define_base_revision d5005

#define_pr_impl_partition -impl_rev_name iofs_pr_afu -partition_name afu_top|port_gasket|pr_slot
define_pr_impl_partition -impl_rev_name iofs_pr_afu -partition_name persona1


