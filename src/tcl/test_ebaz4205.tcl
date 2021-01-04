# Create output directory and clear contents

set xilinxPartNumber xc7z010clg400-1
set outputdir ./project
variable curDir [pwd];
variable scriptDir [file dirname [info script]];


# create output directory and clear outputs
file mkdir $outputdir
set files [glob -nocomplain "$outputdir/*"]
if {[llength $files] != 0} {
    puts "deleting contents of $outputdir"
    file delete -force {*}[glob -directory $outputdir *]; # clear folder contents
} else {
    puts "$outputdir is empty"
}

puts "Creating output directory...";
puts "Current directory: $curDir";
puts "Current script location: $scriptDir";

# create project
create_project -part $xilinxPartNumber project_ebaz4205_tests $outputdir -force

create_bd_design "design_ebaz4205"

# add zynq processor subsystem
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup

# add processor reset
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset0
endgroup

# add AXI bus
#startgroup
#create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0
#endgroup

# setup processing procesing_system7
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_exteral "FIXED_IO, DDR" Master "Disable" Slave "Disable" } [get_bd_cells processing_system7_0]

# apply clock reset setup

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Manual_Source {Auto}}  [get_bd_pins proc_sys_reset0/ext_reset_in]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (50 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins proc_sys_reset0/slowest_sync_clk]
endgroup

#connect clock to processing system
connect_bd_net [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]

regenerate_bd_layout
validate_bd_design
save_bd_design

# create hdl wrapper and make top level 
make_wrapper -files [get_files ./project/project_ebaz4205_tests.srcs/sources_1/bd/design_ebaz4205/design_ebaz4205.bd] -top
add_files -norecurse ./project/project_ebaz4205_tests.gen/sources_1/bd/design_ebaz4205/hdl/design_ebaz4205_wrapper.v


# launch synthesis
launch_runs synth_1
wait_on_run synth_1

# open the gui 
#start_gui
# open the bd_design 
#open_bd_design {project/project_abaz4205_tests.srcs/sources_1/bd/design_ebaz4205/design_ebaz4205.bd}

# run implementation and generate bitstream
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

puts "Implenentation_done!"
