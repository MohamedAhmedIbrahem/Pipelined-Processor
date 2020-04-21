LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE WORK.bus_array_pkg.all;
USE IEEE.numeric_std.all;

ENTITY Mux IS
	GENERIC (selection_line_width : integer := 2;
			 bus_width: integer := 16);
	PORT (
		enable : IN std_logic;  
		selection_lines : IN std_logic_vector(selection_line_width - 1 DOWNTO 0);
		input: IN bus_array((2 ** selection_line_width) - 1 DOWNTO 0)(bus_width - 1 DOWNTO 0);
		output: OUT std_logic_vector(bus_width-1 DOWNTO 0)
	);
END ENTITY mux;

ARCHITECTURE mux_arch OF mux IS
BEGIN
	output <= input(to_integer(unsigned(selection_lines))) WHEN enable = '1' ELSE (OTHERS => 'Z');
END mux_arch;
