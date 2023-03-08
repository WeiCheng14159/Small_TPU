set top top

# Don't change anything below this line
set_host_options -max_cores 16

# Read all Files
read_file -autoread -top ${top} -recursive {../src ../include} -library ${top}
current_design [get_designs ${top}]
link
uniquify

# Setting Clock Constraits
source -echo -verbose ../script/${top}.sdc

compile -map_effort high
compile -map_effort high -inc

remove_unconnected_ports -blast_buses [get_cells -hierarchical *]
 
# Write
write -format ddc -hierarchy -output "${top}_syn.ddc"
write_file -format verilog -hier -output ../syn/${top}_syn.v
write_sdf -version 2.0 -context verilog  ../syn/${top}_syn.sdf
write_sdc -version 2.0 ${top}.sdc
report_area -h > area.log
report_timing > timing.log
report_qor > ${top}_syn.qor
report_power > power.log
exit