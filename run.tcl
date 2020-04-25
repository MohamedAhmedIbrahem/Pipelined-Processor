#! /usr/bin/tclsh

## Assembler
proc Assemble {} {
    if { [catch { exec python Assembler/assembler.py }] } {
        exec python3 Assembler/assembler.py
    }
}

Assemble

vsim CPU  
add wave *
add wave Fetch_Stage/instruction_memory/memory
add wave Memory_Stage/Data_Ram/Mem
add wave Decode_Stage/registers/Register_File

# Remove numeric std warnings before initialization
set NumericStdNoWarnings 1; list
run 0
set NumericStdNoWarnings 0; list

## 2 ^ 32 - 2 didn't work on Data RAM => Modify it
############################
add wave Fetch_Stage/pc_out
add wave Fetch_Stage/pc_in
add wave Fetch_Stage/pc_enable
############################

set ram_contents_file_path CODE_RAM.txt; list
set ram_sim_path "CPU/Fetch_Stage/instruction_memory/memory"; list

set ram_contents_file [open $ram_contents_file_path]; list
set ram_contents [read $ram_contents_file]; list
set ram_contents [string trim $ram_contents]; list
set ram_contents [split $ram_contents "\n"]; list
set end_address [expr {[llength $ram_contents] - 1}]; list

force CLK 1 0, 0 50 -r 100
force RST 1
force INT 0
force Input_Port 2#0
run 100
force RST 0

mem load -filldata $ram_contents $ram_sim_path -endaddress $end_address
run 100