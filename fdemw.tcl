# ----------------------------------------- VARIABLES -----------------------------------------

# Device name
set device "xc7a35tcpg236-1"

set project_name "fdemw_cpu_project"
set top_module "fdemw_top"
set constrain "./cons/cons.xdc"
set nthreads 4

# Find all systemverilog files under .src and save it to the variable.
set sv_files [exec find ./src -name "*.sv"]

# ----------------------------------------- VARIABLES -----------------------------------------

# ----------------------------------------- PROJECT SETUP -------------------------------------

# Create a project and force it.
create_project -force $project_name ./$project_name -part $device

# Add all files to the project.
add_files $sv_files

# Add the constrain file
add_files -fileset constrs_1 $constrain

# Set the top level module explicitly.
set_property top $top_module [current_fileset]

# Reorder the compilation hierarchy.
update_compile_order -fileset sources_1

# ----------------------------------------- PROJECT SETUP -------------------------------------

# ----------------------------------------- SYNTHESIS -----------------------------------------

# Run synthesis with nthreads.
launch_runs synth_1 -jobs $nthreads
wait_on_run synth_1

# Report resource utilization
report_utilization -file ./$project_name/synth_utilization.rpt
report_utilization -hierarchical -file ./$project_name/synth_utilization_hier.rpt

puts "SUCCESS: Synthesis is done."

# ----------------------------------------- SYNTHESIS -----------------------------------------

# ----------------------------------------- IMPLEMENTATION & BITSTREAM ------------------------

launch_runs impl_1 -to_step write_bitstream -jobs $nthreads
wait_on_run impl_1

puts "SUCCESS: Implementation is done."

# ----------------------------------------- IMPLEMENTATION & BITSTREAM ------------------------

# ----------------------------------------- PROGRAMMING THE HARDWARE --------------------------
open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target
set curr_device [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE "./$project_name/$project_name.runs/impl_1/$top_module.bit" $curr_device
program_hw_devices $curr_device

puts "SUCCESS: Hardware has been programmed."

# ----------------------------------------- PROGRAMMING THE HARDWARE --------------------------

close_project
puts "SUCCESS: Project closed."
