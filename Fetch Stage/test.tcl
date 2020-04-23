vsim fetch_stage
add wave *

force clk 1 0, 0 50 -r 100
force rst 1
force pc_enable 1
force is_rst 0
force is_int 0
force pc_write_back 0
run 100

force rst 0
mem load -i Fetch/test_memory.mem instruction_memory/memory
run 100