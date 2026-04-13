# ----------------------------------------- variables -----------------------------------------

set device "xc7a35tcpg236-1"
set project_name "fdemw_tb_project"
set top_module "fdemw_tb"
set constrain "./constrains/constrain.xdc"
set nthreads 4

set sv_files [exec find ./src -name "*.sv"]
set mem_files [exec find ./src -name "*.mem"]

# ----------------------------------------- project setup -------------------------------------

create_project -force $project_name ./$project_name -part $device

# Design + TB sources
add_files -fileset sources_1 $sv_files
add_files -fileset sim_1 $sv_files
add_files -fileset sim_1 $mem_files

# Constraints are not needed for pure behavioral simulation
# add_files -fileset constrs_1 $constrain

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Set testbench as simulation top, not synthesis top
set_property top $top_module [get_filesets sim_1]

# Optional
set_property runtime all [get_filesets sim_1]

# Run simulation only
launch_simulation -simset sim_1 -mode behavioral
close_sim
exit
