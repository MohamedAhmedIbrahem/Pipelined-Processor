LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.bus_array_pkg.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CPU IS
	PORT (
		CLK, RST 						: IN STD_LOGIC;
		Input_Port                                              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Output_Port						: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	     );
END ENTITY;

ARCHITECTURE CPU_Arch OF CPU IS
	COMPONENT IR_LOW IS
    	GENERIC(Size: INTEGER := 16);
    	PORT(
        	CLK, RST, EN    : IN  STD_LOGIC;
        	Din             : IN  STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
        	Dout            : OUT STD_LOGIC_VECTOR(Size-1 DOWNTO 0)
    	);
	END COMPONENT;

	COMPONENT IR_HIGH IS
    	GENERIC(Size: INTEGER := 16);
    	PORT(
       		CLK, RST, EN    : IN  STD_LOGIC;
       	 	Din             : IN  STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
        	Dout            : OUT STD_LOGIC_VECTOR(Size-1 DOWNTO 0)
    	);
	END COMPONENT;

	COMPONENT DC_EX_BUFFER IS
    	PORT(
        	CLK, RST, EN                                    						: IN   STD_LOGIC;
        	Op1,Op2                                         						: IN   STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
        	ALU_Op                                          						: IN   STD_LOGIC_VECTOR(3 DOWNTO 0) ;    -- ALU operation
        	SRC1,SRC2,DST1,DST2                             						: IN   STD_LOGIC_VECTOR(2 DOWNTO 0) ;    -- Registers' Adresses
        	WB1,WB2,WR,RD,I_O,PCWB,FLAGSWB,FLAGS_UPD,IS_SRC1,IS_SRC2  					: IN   STD_LOGIC;   			 -- Signals
        	Op1_EX,Op2_EX                                         						: OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
        	ALU_Op_EX                                          						: OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) ;    -- ALU operation
        	SRC1_EX,SRC2_EX,DST1_EX,DST2_EX                             					: OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) ;    -- Registers' Adresses
        	WB1_EX,WB2_EX,WR_EX,RD_EX,I_O_EX,PCWB_EX,FLAGSWB_EX,FLAGS_UPD_EX,IS_SRC1_EX,IS_SRC2_EX  	: OUT  STD_LOGIC                         -- Signals
   	 );
	END COMPONENT;

	COMPONENT Execute_Stage IS
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
		EX_Forwarding_Stall					: OUT STD_LOGIC;    
		Flags_Register                     			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	     );
	END COMPONENT;

	COMPONENT EX_MEM_BUFFER IS
    	PORT(
		CLK, RST, EN                                    		: IN   STD_LOGIC;
        	Op1, Op2                                         		: IN   STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
        	DST1,DST2                             				: IN   STD_LOGIC_VECTOR(2 DOWNTO 0);     -- Registers' Adresses
        	WB1,WB2,WR,RD,I_O,PCWB,FLAGSWB  				: IN   STD_LOGIC;                        -- Signals
        	Op1_MEM,Op2_MEM                                         	: OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
        	ALU_Op_MEM                                          		: OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);     -- ALU operation
        	DST1_MEM,DST2_MEM                             			: OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);     -- Registers' Adresses
        	WB1_MEM,WB2_MEM,WR_MEM,RD_MEM,I_O_MEM,PCWB_MEM,FLAGSWB_MEM  	: OUT  STD_LOGIC                         -- Signals
    	);
	END COMPONENT;

	COMPONENT Memory_Stage IS
	PORT (
		CLK, RST 						: IN STD_LOGIC;
		Op1_MEM, Op2_MEM                                  	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);     -- operands
        	DST1_MEM, DST2_MEM              			: IN STD_LOGIC_VECTOR(2 DOWNTO 0) ;     -- Registers' Adresses
        	WB1_MEM, WB2_MEM, WR_MEM, RD_MEM, I_O_MEM,
		PCWB_MEM, FLAGSWB_MEM 					: IN STD_LOGIC;
        	Op1_MEM_OUT, Op2_MEM_OUT                  		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
       	 	DST1_MEM_OUT, DST2_MEM_OUT                		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);     -- Registers' Adresses
        	WB1_MEM_OUT, WB2_MEM_OUT, 
		PCWB_MEM_OUT, FLAGSWB_MEM_OUT  				: OUT STD_LOGIC;                        -- Signals
		Output_Port						: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	     );
	END COMPONENT;

	COMPONENT MEM_WB_BUFFER IS
    	PORT(
		CLK, RST, EN                            : IN   STD_LOGIC					 ;
        	Op1,Op2                                 : IN   STD_LOGIC_VECTOR(31 DOWNTO 0) ;    -- operands
        	DST1,DST2                             	: IN   STD_LOGIC_VECTOR(2 DOWNTO 0)  ;    -- Registers' Adresses
        	WB1,WB2,PCWB,FLAGSWB  			: IN   STD_LOGIC					 ;    -- Signals
        	Op1_WB,Op2_WB                           : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0) ;    -- operands
        	DST1_WB,DST2_WB                         : OUT  STD_LOGIC_VECTOR(2 DOWNTO 0)	 ;    -- Registers' Adresses
        	WB1_WB,WB2_WB,PCWB_WB,FLAGSWB_WB  	: OUT  STD_LOGIC					      -- Signals
    	);
	END COMPONENT;

	SIGNAL Op1_EX, Op2_EX, Op1_MEM, Op2_MEM, Op1_WB, Op2_WB 			 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL WB1_EX, WB1_MEM, WB1_WB, WB2_EX, WB2_MEM, WB2_WB 			 : STD_LOGIC;
	SIGNAL PCWB_EX, PCWB_MEM, PCWB_WB, FLAGSWB_EX, FLAGSWB_MEM, FLAGSWB_WB  	 : STD_LOGIC;
	SIGNAL WR_EX, WR_MEM, RD_EX, RD_MEM, I_O_EX, I_O_MEM 				 : STD_LOGIC;
	SIGNAL IS_SRC1_EX, IS_SRC2_EX, FLAGS_UPD_EX 					 : STD_LOGIC;
	SIGNAL ALU_Op_EX, Flags_Register						 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SRC1_EX, SRC2_EX, DST1_EX, DST1_MEM, DST1_WB, DST2_EX, DST2_MEM, DST2_WB  : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL EX_Forwarding_Stall, Fetch_Forwarding_Stall 				 : STD_LOGIC;
BEGIN

EX_Stage : Execute_Stage PORT MAP (CLK, RST, Op1_EX, Op2_EX, ALU_Op_EX, SRC1_EX, SRC2_EX, DST1_EX, DST2_EX,              	        	
				  WB1_EX, WB2_EX, WR_EX, RD_EX, I_O_EX, PCWB_EX, FLAGSWB_EX, FLAGS_UPD_EX, IS_SRC1_EX, IS_SRC2_EX,  	
				  WB1_MEM, WB2_MEM, RD_MEM, I_O_MEM, DST1_MEM, DST2_MEM, Op1_MEM, Op2_MEM, WB1_WB, WB2_WB, FLAGSWB_WB,	 			
				  DST1_WB, DST2_WB, Op1_WB, Op2_WB, Input_Port, Op1_MEM, Op2_MEM, DST1_MEM, DST2_MEM, WB1_MEM, 
				  WB2_MEM, WR_MEM, RD_MEM, I_O_MEM, PCWB_MEM, FLAGSWB_MEM, EX_Forwarding_Stall, Flags_Register);
	
EX_MEM_BUFF : EX_MEM_BUFFER PORT MAP (CLK, (RST OR EX_Forwarding_Stall), '1', Op1_MEM, Op2_MEM, DST1_MEM, DST2_MEM,                             			
        			      WB1_MEM ,WB2_MEM ,WR_MEM ,RD_MEM ,I_O,_MEM, PCWB_MEM ,FLAGSWB_MEM, Op1_MEM, Op2_MEM                                         	
        	ALU_Op_MEM                                          		
        	DST1_MEM,DST2_MEM                             			
        	WB1_MEM,WB2_MEM,WR_MEM,RD_MEM,I_O_MEM,PCWB_MEM,FLAGSWB_MEM  	
    	);
	END COMPONENT;	

END CPU_Arch;
