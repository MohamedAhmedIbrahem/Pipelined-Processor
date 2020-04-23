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
--------------------------------- Fetch Stage Ouput Signals -------------------------------------
	SIGNAL IR_FETCH 								: STD_LOGIC_VECTOR(0 TO 15);		
    	SIGNAL P_TAKEN_FETCH     							: STD_LOGIC;			
	SIGNAL PC_KEY_FETCH 								: STD_LOGIC_VECTOR(3 DOWNTO 0);
--------------------------------- Decode Stage Input Signals -------------------------------------
	SIGNAL IR_HIGH_DEC_IN, IR_LOW_DEC_IN						: STD_LOGIC_VECTOR(0 TO 15);
	SIGNAL P_TAKEN_DEC_IN								: STD_LOGIC;
	SIGNAL P_KEY_DEC_IN  								: STD_LOGIC_VECTOR(3 DOWNTO 0); 
--------------------------------- Decode Stage Output Signals -------------------------------------
	SIGNAL Op1_DEC_OUT, Op2_DEC_OUT							: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL WB1_DEC_OUT, WB2_DEC_OUT, PCWB_DEC_OUT, FLAGSWB_DEC_OUT, 
	       WR_DEC_OUT,  RD_DEC_OUT, I_O_DEC_OUT, 
	       IS_SRC1_DEC_OUT, IS_SRC2_DEC_OUT, FLAGS_UPD_DEC_OUT, JZ_DEC_OUT 		: STD_LOGIC;
	SIGNAL ALU_OP_DEC_OUT							 	: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SRC1_DEC_OUT, SRC2_DEC_OUT, DST1_DEC_OUT, DST2_DEC_OUT			: STD_LOGIC_VECTOR(0 TO 2);
--------------------------------- Execute Stage Intput Signals -------------------------------------
	SIGNAL Op1_EX_IN, Op2_EX_IN 							: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL WB1_EX_IN, WB2_EX_IN, PCWB_EX_IN, FLAGSWB_EX_IN, WR_EX_IN, 
		RD_EX_IN, I_O_EX_IN, IS_SRC1_EX_IN, IS_SRC2_EX_IN, FLAGS_UPD_EX_IN 	: STD_LOGIC;
	SIGNAL ALU_Op_EX_IN								: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SRC1_EX_IN, SRC2_EX_IN, DST1_EX_IN, DST2_EX_IN 				: STD_LOGIC_VECTOR(0 TO 2);
--------------------------------- Execute Stage Output Signals -------------------------------------
	SIGNAL Op1_EX_OUT, Op2_EX_OUT							: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL WB1_EX_OUT,  WB2_EX_OUT, PCWB_EX_OUT, FLAGSWB_EX_OUT, 
	       WR_EX_OUT, RD_EX_OUT, I_O_EX_OUT  					: STD_LOGIC;
	SIGNAL DST1_EX_OUT, DST2_EX_OUT 						: STD_LOGIC_VECTOR(0 TO 2);
--------------------------------- Memory Stage Input Signals -------------------------------------
	SIGNAL Op1_MEM_IN, Op2_MEM_IN 							: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL WB1_MEM_IN, WB2_MEM_IN, PCWB_MEM_IN, FLAGSWB_MEM_IN,
	       WR_MEM_IN,  RD_MEM_IN,  I_O_MEM_IN  					: STD_LOGIC;
	SIGNAL DST1_MEM_IN, DST2_MEM_IN							: STD_LOGIC_VECTOR(0 TO 2);
--------------------------------- Memory Stage Output Signals -------------------------------------
	SIGNAL Op1_MEM_OUT, Op2_MEM_OUT							: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL WB1_MEM_OUT, WB2_MEM_OUT, PCWB_MEM_OUT, FLAGSWB_MEM_OUT  		: STD_LOGIC;
	SIGNAL DST1_MEM_OUT, DST2_MEM_OUT 						: STD_LOGIC_VECTOR(0 TO 2);
----------------------------------  Write Back Stage Signals ----------------------------------------
	SIGNAL Op1_WB, Op2_WB 								: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL WB1_WB, WB2_WB, PCWB_WB, FLAGSWB_WB		 			: STD_LOGIC;
	SIGNAL DST1_WB, DST2_WB 							: STD_LOGIC_VECTOR(0 TO 2);
----------------------------------  Other Signals ---------------------------------------- 
	SIGNAL EX_Forwarding_Stall, Fetch_Forwarding_Stall 				: STD_LOGIC;
	SIGNAL Flags      	            						: STD_LOGIC_VECTOR(3 DOWNTO 0);		
BEGIN

FETCH_DC_BUFF :	 ENTITY work.FETCH_DC_BUFFER PORT MAP (CLK, RST, (NOT EX_Forwarding_Stall), 
					 (EX_Forwarding_Stall NOR ((NOT IR_FETCH(0)) AND IR_FETCH(1))),  
        				  P_TAKEN_FETCH, P_TAKEN_DEC_IN, PC_KEY_FETCH, P_KEY_DEC_IN,
	    				  IR_FETCH, IR_HIGH_DEC_IN, IR_HIGH_DEC_IN);

--pc_transparent, RD3_address, RD3_data
DEC_Stage : ENTITY work.Decode_Stage PORT MAP (CLK, RST, IR_HIGH_DEC_IN, IR_LOW_DEC_IN, (NOT EX_Forwarding_Stall),  
	        		   pc_transparent, Flags, Op1_DEC_OUT, Op2_DEC_OUT, ALU_OP_DEC_OUT,
				   FLAGS_UPD_DEC_OUT, WB1_DEC_OUT, WB2_DEC_OUT, WR_DEC_OUT, RD_DEC_OUT,
				   I_O_DEC_OUT, PCWB_DEC_OUT, FLAGSWB_DEC_OUT, SRC1_DEC_OUT, SRC2_DEC_OUT,
	        		   IS_SRC1_DEC_OUT, IS_SRC2_DEC_OUT, DST1_DEC_OUT, DST2_DEC_OUT, JZ_DEC_OUT,  
	        		   WB1_WB, WB2_WB, DST1_WB, DST2_WB, Op1_WB, Op2_WB, RD3_address, RD3_data);

DC_EX_BUFF : ENTITY work.DC_EX_BUFFER PORT MAP (CLK, RST, (NOT EX_Forwarding_Stall),                                     						
        	 		    Op1_DEC_OUT, Op2_DEC_OUT, ALU_OP_DEC_OUT, SRC1_DEC_OUT, SRC2_DEC_OUT, DST1_DEC_OUT, DST2_DEC_OUT,                            						    
        			    WB1_DEC_OUT, WB2_DEC_OUT, WR_DEC_OUT, RD_DEC_OUT, I_O_DEC_OUT, PCWB_DEC_OUT, FLAGSWB_DEC_OUT,
				    FLAGS_UPD_DEC_OUT, IS_SRC1_DEC_OUT, IS_SRC2_DEC_OUT, Op1_EX_IN, Op2_EX_IN, 
				    ALU_Op_EX_IN, SRC1_EX_IN, SRC2_EX_IN, DST1_EX_IN, DST2_EX_IN, WB1_EX_IN, 
				    WB2_EX_IN, WR_EX_IN, RD_EX_IN, I_O_EX_IN, PCWB_EX_IN, FLAGSWB_EX_IN, 
				    FLAGS_UPD_EX_IN, IS_SRC1_EX_IN, IS_SRC2_EX_IN);
	
EX_Stage : ENTITY work.Execute_Stage PORT MAP (CLK, RST, Op1_EX_IN, Op2_EX_IN, ALU_Op_EX_IN, SRC1_EX_IN, SRC2_EX_IN, DST1_EX_IN, DST2_EX_IN,              	        	
				   WB1_EX_IN, WB2_EX_IN, WR_EX_IN, RD_EX_IN, I_O_EX_IN, PCWB_EX_IN, FLAGSWB_EX_IN, 
				   FLAGS_UPD_EX_IN, IS_SRC1_EX_IN, IS_SRC2_EX_IN, WB1_MEM_IN, WB2_MEM_IN, RD_MEM_IN, 
				   I_O_MEM_IN, DST1_MEM_IN, DST2_MEM_IN, Op1_MEM_IN, Op2_MEM_IN, WB1_WB, WB2_WB, FLAGSWB_WB,	 			
				   DST1_WB, DST2_WB, Op1_WB, Op2_WB, Input_Port, 
				   Op1_EX_OUT, Op2_EX_OUT, DST1_EX_OUT, DST2_EX_OUT, WB1_EX_OUT, 
				   WB2_EX_OUT, WR_EX_OUT, RD_EX_OUT, I_O_EX_OUT, PCWB_EX_OUT, FLAGSWB_EX_OUT, 
				   EX_Forwarding_Stall, Flags);
	
EX_MEM_BUFF : ENTITY work.EX_MEM_BUFFER PORT MAP (CLK, (RST OR EX_Forwarding_Stall), '1', Op1_EX_OUT, Op2_EX_OUT, DST1_EX_OUT, DST2_EX_OUT,                             			
        			      WB1_EX_OUT, WB2_EX_OUT, WR_EX_OUT, RD_EX_OUT, I_O_EX_OUT, PCWB_EX_OUT, FLAGSWB_EX_OUT, 
				      Op1_MEM_IN, Op2_MEM_IN, DST1_MEM_IN, DST2_MEM_IN, WB1_MEM_IN, WB2_MEM_IN, 
				      WR_MEM_IN, RD_MEM_IN, I_O_MEM_IN, PCWB_MEM_IN, FLAGSWB_MEM_IN);

MEM_Stage : ENTITY work.Memory_Stage PORT MAP (CLK, RST, Op1_MEM_IN, Op2_MEM_IN, DST1_MEM_IN, DST2_MEM_IN, WB1_MEM_IN, WB2_MEM_IN, 
				    WR_MEM_IN, RD_MEM_IN, I_O_MEM_IN, PCWB_MEM_IN, FLAGSWB_MEM_IN, Op1_MEM_OUT, Op2_MEM_OUT,                  		
       	 			    DST1_MEM_OUT, DST2_MEM_OUT, WB1_MEM_OUT, WB2_MEM_OUT, PCWB_MEM_OUT, FLAGSWB_MEM_OUT, Output_Port); 
		 				
MEM_WB_BUFF : ENTITY work.MEM_WB_BUFFER PORT MAP (CLK, RST, '1', Op1_MEM_OUT, Op2_MEM_OUT, DST1_MEM_OUT, DST2_MEM_OUT, 
			            WB1_MEM_OUT, WB2_MEM_OUT, PCWB_MEM_OUT, FLAGSWB_MEM_OUT, Op1_WB, Op2_WB, 
				    DST1_WB, DST2_WB, WB1_WB, WB2_WB, PCWB_WB, FLAGSWB_WB);  	


END CPU_Arch;
