############################################################################################
#                               PARTIAL RECONFIGURATION                                    #
############################################################################################

set_global_assignment -name REVISION_TYPE PR_BASE
set_instance_assignment -name PARTITION persona1 -to afu_top|port_gasket|pr_slot|afu_main -entity iofs_top
set_instance_assignment -name PARTIAL_RECONFIGURATION_PARTITION ON -to afu_top|port_gasket|pr_slot|afu_main -entity iofs_top
set_instance_assignment -name PLACE_REGION "X240 Y0 X280 Y430;X75 Y40 X76 Y109;X77 Y40 X204 Y320;X67 Y110 X76 Y320;X205 Y110 X239 Y320;X75 Y321 X203 Y393" -to afu_top|port_gasket|pr_slot|afu_main
set_instance_assignment -name ROUTE_REGION "0 0 282 432" -to afu_top|port_gasket|pr_slot|afu_main
set_instance_assignment -name RESERVE_PLACE_REGION ON -to afu_top|port_gasket|pr_slot|afu_main
set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|port_gasket|pr_slot|afu_main
