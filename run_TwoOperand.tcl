#!/usr/bin/tclsh

### Parameters
set code_file_path "TestCases/TwoOperand.asm"; list
set code_ram_file_path "code_ram.txt"; list
set data_ram_file_path "data_ram.txt"; list
set instruction_memory_sim_path "CPU/Fetch_Stage/instruction_memory"; list
set data_memory_sim_path "CPU/Memory_Stage/Data_Ram"; list

### Run the assembler to generate ram contents
if {[catch { exec python Assembler/assembler.py $code_file_path $code_ram_file_path $data_ram_file_path }]} {
    exec python3 Assembler/assembler.py $code_file_path $code_ram_file_path $data_ram_file_path
}


### Initialize simulation
vsim CPU  
#add wave -unsigned *
#add wave -unsigned CPU/Fetch_Stage/fetch_forwarding_unit/*
#add wave -unsigned CPU/Execute_Stage/EX_FORW_UNIT/*
add wave CLK
add wave RST
add wave INT
add wave -unsigned $instruction_memory_sim_path/memory   
add wave -unsigned $data_memory_sim_path/Mem
add wave -hexadecimal Decode_Stage/registers/Register_File
add wave -hexadecimal Input_Port 
add wave -hexadecimal Output_Port
add wave flags

# Remove numeric std warnings before initialization
set NumericStdNoWarnings 1; list
run 0
set NumericStdNoWarnings 0; list

############################
add wave -label PC -hexadecimal Fetch_Stage/pc_out
add wave -label SP -hexadecimal { Decode_stage/sp_data_out (10 DOWNTO 0) }
#add wave -radix unsigned Fetch_Stage/pc_in
#add wave Fetch_Stage/pc_enable
#add wave Fetch_Stage/instruction_read
#add wave Fetch_Stage/RET_Fetch
#add wave Fetch_Stage/int_internal
#add wave Execute_Stage/*
############################

### Load instruction memory
# Load internal instructions
set instruction_memory_size [examine -unsigned $instruction_memory_sim_path/MEMORY_SIZE]; list
set start_address [examine -unsigned Fetch_Stage/INTERNAL_INSTRUCTIONS_START_ADDRESS]; list
set internal_instructions {
    0000011000000000
    0000111000000000
	1000000000000010
    0101111000000000
    0001101000000000
    1000000000000000
    0110000000000000
}; list
mem load -filldata $internal_instructions $instruction_memory_sim_path/memory -startaddress $start_address

# Load code
set ram_contents_file [open $code_ram_file_path]; list
set ram_contents [read $ram_contents_file]; list
set ram_contents [string trim $ram_contents]; list
set ram_contents [split $ram_contents "\n"]; list
set end_address [expr {[llength $ram_contents] - 1}]; list
mem load -filldata $ram_contents $instruction_memory_sim_path/memory -startaddress 0 -endaddress $end_address

### Load data memory
set ram_contents_file [open $data_ram_file_path]; list
set ram_contents [read $ram_contents_file]; list
set ram_contents [string trim $ram_contents]; list
set ram_contents [split $ram_contents "\n"]; list
set end_address [expr {[llength $ram_contents] - 1}]; list
mem load -filldata $ram_contents $data_memory_sim_path/Mem -endaddress $end_address


### Initialize CLK and RST
force CLK 1 0, 0 50 -r 100
force RST 1
force INT 0
force Input_Port 16#0
run 100
force RST 0
run 800
force Input_Port 16#5
run 100
force Input_Port 16#19
run 100
force Input_Port 16#FFFD
run 100
force Input_Port 16#F320
run 2000


