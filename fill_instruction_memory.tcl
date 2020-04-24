delete wave *
add wave *
add wave Fetch_Stage/instruction_memory/memory

set ram_contents_file_path CODE_RAM.txt; list
set ram_sim_path "CPU/Fetch_Stage/instruction_memory/memory"; list

set ram_contents_file [open $ram_contents_file_path]; list
set ram_contents [read $ram_contents_file]; list
set ram_contents [string trim $ram_contents]; list
set ram_contents [split $ram_contents "\n"]; list
echo $ram_contents;
mem load -filldata $ram_contents $ram_sim_path
