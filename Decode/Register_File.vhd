LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.bus_array_pkg.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Register_File IS
	PORT (
		CLK, RST 						: IN STD_LOGIC;
		Port1_RD_Address, Port2_RD_Address, Port3_RD_Address 	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		Port1_RD_Op, Port2_RD_Op, Port3_RD_Op 			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		Port1_WR_Address, Port2_WR_Address 			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		Port1_WR_Op, Port2_WR_Op 				: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Port1_WR_Enable, Port2_WR_Enable 			: IN STD_LOGIC
	);
END ENTITY;

ARCHITECTURE Register_File_Arch OF Register_File IS
	SIGNAL Register_File : bus_array(0 TO 7)(31 DOWNTO 0);
BEGIN
	PROCESS (CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			IF RST = '1' THEN
				Register_File <= (OTHERS => (OTHERS => '0'));
			ELSE
				IF Port1_WR_Enable = '1' THEN
					Register_File(to_integer(unsigned(Port1_WR_Address))) <= Port1_WR_Op;
				END IF;
				IF Port2_WR_Enable = '1' THEN
					Register_File(to_integer(unsigned(Port2_WR_Address))) <= Port2_WR_Op;
				END IF;
			END IF;
		END IF;
	END PROCESS;

Port1_RD_Op <= Register_File(to_integer(unsigned(Port1_RD_Address)));
Port2_RD_Op <= Register_File(to_integer(unsigned(Port2_RD_Address)));
Port3_RD_Op <= Register_File(to_integer(unsigned(Port3_RD_Address)));
END Register_File_Arch;