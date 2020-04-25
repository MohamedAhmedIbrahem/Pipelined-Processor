## Assembler
proc Assemble {} {
    set output [exec python Assembler/assembler.py]
    puts $output
}

Assemble

vsim CPU  
add wave *
add wave Fetch_Stage/instruction_memory/memory
add wave Fetch_Stage/pc_out
add wave Fetch_Stage/pc_in
add wave Fetch_Stage/pc_enable

set ram_contents_file_path Assembler/CODE_RAM.txt; list
set ram_sim_path "CPU/Fetch_Stage/instruction_memory/memory"; list

set ram_contents_file [open $ram_contents_file_path]; list
set ram_contents [read $ram_contents_file]; list
set ram_contents [string trim $ram_contents]; list
set ram_contents [split $ram_contents "\n"]; list
set end_address [expr {[llength $ram_contents] - 1}]

force -deposit /CLK 1 0, 0 50 -r 100
force -deposit /RST 1
force -deposit /INT 0
force -deposit /Input_Port 2#0
run 100
force -deposit /RST 0

mem load -filldata $ram_contents $ram_sim_path -endaddress $end_address
run 100