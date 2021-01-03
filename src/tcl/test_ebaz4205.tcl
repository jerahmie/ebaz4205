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
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 procesing_system7_0
endgroup


regenerate_bd_layout
save_bd_design