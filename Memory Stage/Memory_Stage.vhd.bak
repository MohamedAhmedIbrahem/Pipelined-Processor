LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.bus_array_pkg.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Memory_Stage IS
	PORT (
		CLK, RST 						: IN STD_LOGIC;
		Op1_MEM, Op2_MEM                                  	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);     -- operands
        	DST1_MEM, DST2_MEM              			: IN STD_LOGIC_VECTOR(0 TO 2);	        -- Registers' Adresses
        	WB1_MEM, WB2_MEM, WR_MEM, RD_MEM, I_O_MEM,
		PCWB_MEM, FLAGSWB_MEM 					: IN STD_LOGIC;
        	Op1_MEM_OUT, Op2_MEM_OUT                  		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
       	 	DST1_MEM_OUT, DST2_MEM_OUT                		: OUT STD_LOGIC_VECTOR(0 TO 2);	        -- Registers' Adresses
        	WB1_MEM_OUT, WB2_MEM_OUT, 
		PCWB_MEM_OUT, FLAGSWB_MEM_OUT  				: OUT STD_LOGIC;                        -- Signals
		Output_Port						: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	     );
END ENTITY;

ARCHITECTURE Memory_Stage_Arch OF Memory_Stage IS

	SIGNAL RAM_OUT : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL WB_Op1_MUX_Input: bus_array(1 DOWNTO 0)(31 DOWNTO 0);
	SIGNAL WB_Op1_MUX_Enable : STD_LOGIC_VECTOR(0 DOWNTO 0);
BEGIN
  	Data_Ram : ENTITY work.DATA_RAM GENERIC MAP(16, 32) PORT MAP(CLK, (WR_MEM AND I_O_MEM), (RD_MEM AND I_O_MEM), '0', Op2_MEM, Op1_MEM, RAM_OUT);

	WB_Op1_MUX_Input(0) <= Op1_MEM;
	WB_Op1_MUX_Input(1) <= RAM_OUT;
	WB_Op1_MUX_Enable(0) <= (RD_MEM AND I_O_MEM);
	MEM_Op1_MUX  : ENTITY work.Mux GENERIC MAP (selection_line_width => 1, bus_width => 32) PORT MAP ('1', WB_Op1_MUX_Enable, WB_Op1_MUX_Input, Op1_MEM_OUT);

	OUT_PORT : ENTITY work.RISING_EDGE_REG GENERIC MAP (32) PORT MAP (CLK, RST, (WR_MEM AND NOT I_O_MEM), Op1_MEM, Output_Port);
	
	Op2_MEM_OUT <= Op2_MEM;               		
       	DST1_MEM_OUT <= DST1_MEM; 
	DST2_MEM_OUT <= DST2_MEM;           		
        WB1_MEM_OUT <= WB1_MEM;
	WB2_MEM_OUT <= WB2_MEM;
	PCWB_MEM_OUT <= PCWB_MEM;
	FLAGSWB_MEM_OUT <= FLAGSWB_MEM;  				
END Memory_Stage_Arch;
