*To run any test case:

1. Create project and add all vhdl files.
2. Compile all files 3 times to resolve dependencies.
3. do Scripts/run_<case>.tcl

This runs the assembler to generate the memory text file, loads the file and runs the appropriate test case.
The memory text files are provided just in case.

*When PC = 80.... then an internal instruction (executing INT, RTI, RST,.. is being executed).

*When an INT occurs while a jump is being executed, the INT execution until the jump is executed.

*A read/write miss in instruction/data cache takes 6 cycles (1 to check for hit, 4 to transfer data to cache, then 1 to read/write to cache).