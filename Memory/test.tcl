vsim memory_controller

add wave *
add wave main_memory/Mem
add wave instruction_cache/cache
add wave data_cache/cache

set NumericStdNoWarnings 1; list
run 0
set NumericStdNoWarnings 0; list

force clk 1 0, 0 50 -r 100
force rst 1
run 100
force data_read 0
force data_write 0
force instruction_read 0
force rst 0

mem load -filldata 0 main_memory/Mem -filltype rand
run 100