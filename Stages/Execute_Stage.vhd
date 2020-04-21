LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.bus_array_pkg.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Execute_Stage IS
	PORT (
		CLK, RST 						: IN STD_LOGIC;
		Op1_EX, Op2_EX                                  	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);     -- operands
        	ALU_Op_EX                                       	: IN STD_LOGIC_VECTOR(3 DOWNTO 0) ;     -- ALU operation
        	SRC1_EX, SRC2_EX, DST1_EX, DST2_EX              	: IN STD_LOGIC_VECTOR(2 DOWNTO 0) ;     -- Registers' Adresses
        	WB1_EX, WB2_EX, WR_EX, RD_EX, I_O_EX, PCWB_EX, 
		FLAGSWB_EX, FLAGS_UPD_EX, IS_SRC1_EX, IS_SRC2_EX  	: IN STD_LOGIC;  			-- Signals 
		WB1_MEM, WB2_MEM, RD_MEM, I_O_MEM 			: IN STD_LOGIC; 			-- Memory Stage Signals
		DST1_MEM, DST2_MEM 					: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 	-- Memory Stage DST Addresses
		Op1_MEM, Op2_MEM 					: IN STD_LOGIC_VECTOR(31 DOWNTO 0);	-- Memory Stage DST Registers
		WB1_WB, WB2_WB, FLAGSWB_WB	 			: IN STD_LOGIC; 			-- Write Back Stage Signals
		DST1_WB, DST2_WB 					: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 	-- Write Back Stage DST Addresses
		Op1_WB, Op2_WB						: IN STD_LOGIC_VECTOR(31 DOWNTO 0); 	-- Write Back Stage DST Registers
		Input_Port                              		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        	Op1_EX_OUT, Op2_EX_OUT                  		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
       	 	DST1_EX_OUT, DST2_EX_OUT                		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);     -- Registers' Adresses
        	WB1_EX_OUT, WB2_EX_OUT, WR_EX_OUT, 
		RD_EX_OUT, I_O_EX_OUT, PCWB_EX_OUT, FLAGSWB_EX_OUT  	: OUT STD_LOGIC;                        -- Signals 
		Flags_Register                     			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	     );
END ENTITY;

ARCHITECTURE Execute_Stage_Arch OF Execute_Stage IS

	COMPONENT ALU IS
		PORT (
			A, B 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OP 		: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			C 		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			FLAGS 		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- C & N & Z
		);
	END COMPONENT;

	COMPONENT Execute_Forwarding_Unit IS
		PORT (
			CLK, RST 				: IN STD_LOGIC;
			IS_SRC1_EX, IS_SRC2_EX 			: IN STD_LOGIC; 			-- Execute Stage Signals
			SRC1_EX, SRC2_EX 			: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 	-- Execute Stage SRC Addresses
			WB1_MEM, WB2_MEM, RD_MEM, I_O_MEM 	: IN STD_LOGIC; 			-- Memory Stage Signals
			DST1_MEM, DST2_MEM 			: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 	-- Memory Stage DST Addresses
			Op1_MEM, Op2_MEM 			: IN STD_LOGIC_VECTOR(31 DOWNTO 0);	-- Memory Stage DST Registers
			WB1_WB, WB2_WB				: IN STD_LOGIC; 			-- Write Back Stage Signals
			DST1_WB, DST2_WB 			: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 	-- Write Back Stage DST Addresses
			Op1_WB, Op2_WB 				: IN STD_LOGIC_VECTOR(31 DOWNTO 0); 	-- Write Back Stage DST Registers
			Op1_EX_Forwarding_Enable,
			Op2_EX_Forwarding_Enable,
			EX_Forwarding_Stall 			: OUT STD_LOGIC; 			-- Forwarding Enables & Stall Signals
			Op1_EX_Forwarded, Op2_EX_Forwarded 	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 	-- The Forwarded Operands
		);
	END COMPONENT;

	COMPONENT Mux IS
		GENERIC (
			selection_line_width : INTEGER := 2;
			bus_width : INTEGER := 16);
		PORT (
			enable : IN std_logic;
			selection_lines : IN std_logic_vector(selection_line_width - 1 DOWNTO 0);
			input : IN bus_array((2 ** selection_line_width) - 1 DOWNTO 0)(bus_width - 1 DOWNTO 0);
			output : OUT std_logic_vector(bus_width - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT RISING_EDGE_REG IS
    		GENERIC(
			Size: INTEGER := 32);
    		PORT(
       			CLK, RST, EN    : IN  STD_LOGIC;
        		Din             : IN  STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
       			Dout            : OUT STD_LOGIC_VECTOR(Size-1 DOWNTO 0)
   		 );
	END COMPONENT;

	SIGNAL ALU_Op1_MUX_Input: bus_array(1 DOWNTO 0)(31 DOWNTO 0);
	SIGNAL ALU_Op2_MUX_Input: bus_array(1 DOWNTO 0)(31 DOWNTO 0);
	SIGNAL MEM_Op1_MUX_Input: bus_array(1 DOWNTO 0)(31 DOWNTO 0);
	SIGNAL Flags_MUX_Input: bus_array(1 DOWNTO 0)(3 DOWNTO 0);
	SIGNAL Op1_Forwarding_Enable, Op2_Forwarding_Enable, Forwarding_Stall : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL Op1_Forwarded, Op2_Forwarded : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_Op1, ALU_Op2, ALU_Result : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_Flags, WB_Flags, Flags_MUX_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL FLAGSWB_WB_TMP, MEM_Op1_MUX_Enable : STD_LOGIC_VECTOR(0 DOWNTO 0);
BEGIN
  	
	EX_FORW_UNIT : Execute_Forwarding_Unit PORT MAP (CLK, RST, IS_SRC1_EX, IS_SRC2_EX, SRC1_EX, SRC2_EX, WB1_MEM, WB2_MEM, RD_MEM, I_O_MEM, 	
			DST1_MEM, DST2_MEM, Op1_MEM, Op2_MEM, WB1_WB, WB2_WB, DST1_WB, DST2_WB, Op1_WB, Op2_WB, Op1_Forwarding_Enable(0),
			Op2_Forwarding_Enable(0), Forwarding_Stall(0), Op1_Forwarded, Op2_Forwarded); 	

	ALU_Op1_MUX_Input(0) <= Op1_EX;
	ALU_Op1_MUX_Input(1) <= Op1_Forwarded;
	ALU_Op1_MUX  : Mux GENERIC MAP (selection_line_width => 1, bus_width => 32) PORT MAP ('1', Op1_Forwarding_Enable, ALU_Op1_MUX_Input, ALU_Op1);

	ALU_Op2_MUX_Input(0) <= Op2_EX;
	ALU_Op2_MUX_Input(1) <= Op2_Forwarded;
	ALU_Op2_MUX  : Mux GENERIC MAP (selection_line_width => 1, bus_width => 32) PORT MAP ('1', Op2_Forwarding_Enable, ALU_Op2_MUX_Input, ALU_Op2);

	ALU_MODULE   : ALU PORT MAP (ALU_Op1, ALU_Op2, ALU_Op_EX, ALU_Result, ALU_Flags);

	WB_Flags <= Op1_WB(3 DOWNTO 0);
	FLAGSWB_WB_TMP(0) <= FLAGSWB_WB;
	Flags_MUX_Input(0) <= ALU_Flags;
	Flags_MUX_Input(1) <= WB_Flags;
	Flags_MUX    : Mux GENERIC MAP (selection_line_width => 1, bus_width => 4)  PORT MAP ('1', FLAGSWB_WB_TMP, Flags_MUX_Input, Flags_MUX_OUT);
	Flags_Reg  : RISING_EDGE_REG GENERIC MAP (4) PORT MAP (CLK, RST, (FLAGSWB_WB OR FLAGS_UPD_EX), Flags_MUX_OUT, Flags_Register);

	MEM_Op1_MUX_Input(0) <= ALU_Result;
	MEM_Op1_MUX_Input(1) <= Input_Port;
	MEM_Op1_MUX_Enable(0) <= (RD_EX AND NOT I_O_EX);
	MEM_Op1_MUX  : Mux GENERIC MAP (selection_line_width => 1, bus_width => 32) PORT MAP ('1', MEM_Op1_MUX_Enable, MEM_Op1_MUX_Input, Op1_EX_OUT);

	Op2_EX_OUT <= Op2_EX;
	WB1_EX_OUT <= WB1_EX;
	WB2_EX_OUT <= WB2_EX;
	WR_EX_OUT <= WR_EX;
	RD_EX_OUT <= RD_EX;
	I_O_EX_OUT <= I_O_EX; 
	PCWB_EX_OUT <= PCWB_EX; 
	FLAGSWB_EX_OUT <= FLAGSWB_EX;    
	DST1_EX_OUT <= DST1_EX;
	DST2_EX_OUT <= DST2_EX;

END Execute_Stage_Arch;