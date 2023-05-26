set QSYS_SIMDIR $env(WORKDIR)/sim/scripts/qip_sim_script
cd $env(WORKDIR)/verification/msim_ip_libraries
if {[file exists $env(WORKDIR)/sim/scripts/qip_sim_script/mentor/msim_setup.tcl]} {
  do $env(WORKDIR)/sim/scripts/qip_sim_script/mentor/msim_setup.tcl USER_DEFINED_COMPILE_OPTIONS="+define+__ALTERA_STD__METASTABLE_SIM"
  ld_debug
}
quit -f
