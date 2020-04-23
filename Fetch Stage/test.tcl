vsim fetch_stage
add wave *
add wave branch_predictor/prediction_cache/fsm_predicted_taken
radix -unsigned

set NumericStdNoWarnings 1; list
run 0
set NumericStdNoWarnings 0; list

force clk 1 0, 0 50 -r 100
force rst 1
force pc_enable 1
force rst_external 0
force int_external 0
force pc_write_back 0
force jz_decode 0
force z_forwarded 0
force prediction_cache_key_decode 0000
run 100

force rst 0
mem load -i "Fetch Stage/test_memory.mem" instruction_memory/memory
run 100