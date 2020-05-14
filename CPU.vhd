LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.bus_array_pkg.ALL;
USE WORK.mode_type.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CPU IS
	PORT (
		CLK, RST, INT 						: IN STD_LOGIC;
		Input_Port                                              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Output_Port						: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	     );
END ENTITY;

ARCHITECTURE CPU_Arch OF CPU IS
--------------------------------- Decode Stage Input Signals -------------------------------------
	SIGNAL IR_HIGH_DEC_IN, IR_LOW_DEC_IN						: STD_LOGIC_VECTOR(0 TO 15);
	SIGNAL PC_KEY_DEC_IN  								: STD_LOGIC_VECTOR(3 DOWNTO 0); 
	SIGNAL P_TAKEN_DEC_IN								: STD_LOGIC;
--------------------------------- Execute Stage Intput Signals -------------------------------------
	SIGNAL Op1_EX_IN, Op2_EX_IN 							: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_Op_EX_IN								: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SRC1_EX_IN, SRC2_EX_IN, DST1_EX_IN, DST2_EX_IN 				: STD_LOGIC_VECTOR(0 TO 2);
	SIGNAL WB1_EX_IN, WB2_EX_IN, PCWB_EX_IN, FLAGSWB_EX_IN, WR_EX_IN, 
		RD_EX_IN, I_O_EX_IN, IS_SRC1_EX_IN, IS_SRC2_EX_IN, FLAGS_UPD_EX_IN 	: STD_LOGIC;
--------------------------------- Memory Stage Input Signals -------------------------------------
	SIGNAL Op1_MEM_IN, Op2_MEM_IN 							: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DST1_MEM_IN, DST2_MEM_IN							: STD_LOGIC_VECTOR(0 TO 2);
	SIGNAL WB1_MEM_IN, WB2_MEM_IN, PCWB_MEM_IN, FLAGSWB_MEM_IN,
	       WR_MEM_IN,  RD_MEM_IN,  I_O_MEM_IN  					: STD_LOGIC;
--------------------------------- Fetch Stage Ouput Signals -------------------------------------
	SIGNAL PC_Transparent 								: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL IR_FETCH 								: STD_LOGIC_VECTOR(0 TO 15);		
    	SIGNAL P_TAKEN_FETCH, False_Prediction_FETCH     				: STD_LOGIC;			
	SIGNAL PC_KEY_FETCH 								: STD_LOGIC_VECTOR(3 DOWNTO 0);
--------------------------------- Decode Stage Output Signals -------------------------------------
	SIGNAL Op1_DEC_OUT, Op2_DEC_OUT, Port3_DEC_OUT					: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_OP_DEC_OUT							 	: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SRC1_DEC_OUT, SRC2_DEC_OUT, DST1_DEC_OUT, DST2_DEC_OUT			: STD_LOGIC_VECTOR(0 TO 2);
	SIGNAL WB1_DEC_OUT, WB2_DEC_OUT, PCWB_DEC_OUT, FLAGSWB_DEC_OUT, 
	       WR_DEC_OUT,  RD_DEC_OUT, I_O_DEC_OUT, 
	       IS_SRC1_DEC_OUT, IS_SRC2_DEC_OUT, FLAGS_UPD_DEC_OUT, JZ_DEC_OUT 		: STD_LOGIC;
--------------------------------- Execute Stage Output Signals -------------------------------------
	SIGNAL Op1_EX_OUT, Op2_EX_OUT							: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DST1_EX_OUT, DST2_EX_OUT 						: STD_LOGIC_VECTOR(0 TO 2);
	SIGNAL WB1_EX_OUT,  WB2_EX_OUT, PCWB_EX_OUT, FLAGSWB_EX_OUT, 
	       WR_EX_OUT, RD_EX_OUT, I_O_EX_OUT  					: STD_LOGIC;
--------------------------------- Memory Stage Output Signals -------------------------------------
	SIGNAL Op1_MEM_OUT, Op2_MEM_OUT							: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DST1_MEM_OUT, DST2_MEM_OUT 						: STD_LOGIC_VECTOR(0 TO 2);
	SIGNAL WB1_MEM_OUT, WB2_MEM_OUT, PCWB_MEM_OUT, FLAGSWB_MEM_OUT  		: STD_LOGIC;
----------------------------------  Write Back Stage Signals ----------------------------------------
	SIGNAL Op1_WB, Op2_WB 								: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DST1_WB, DST2_WB 							: STD_LOGIC_VECTOR(0 TO 2);
	SIGNAL WB1_WB, WB2_WB, PCWB_WB, FLAGSWB_WB		 			: STD_LOGIC;
----------------------------------  Other Signals ---------------------------------------- 
	SIGNAL Flags      	            						: STD_LOGIC_VECTOR(3 DOWNTO 0);	
	SIGNAL EX_Forwarding_Stall, Fetch_Forwarding_Stall, PCWB_Stall, PCWB_Stall_PC_enable : STD_LOGIC;
        CONSTANT w_Mode: Mode := None;
	
BEGIN

PCWB_Stall_PC_enable <= PCWB_DEC_OUT OR PCWB_EX_IN OR PCWB_MEM_IN;
PCWB_Stall <= PCWB_Stall_PC_enable OR PCWB_WB;

---------------------------------------------- Fetch Stage ----------------------------------------------------------
Fetch_Stage : ENTITY work.Fetch_Stage GENERIC MAP (16, 32, 4, w_Mode)  
								PORT MAP (CLK, RST, NOT (Fetch_Forwarding_Stall OR PCWB_Stall_PC_enable OR EX_Forwarding_Stall),
								       INT, PCWB_WB, P_TAKEN_DEC_IN, JZ_DEC_OUT, Flags(0), PCWB_Stall,
								       Port3_DEC_OUT, Op1_WB, PC_KEY_DEC_IN, WB1_DEC_OUT, WB2_DEC_OUT,
								       WB1_EX_IN, WB2_EX_IN, WB1_MEM_IN, WB2_MEM_IN, RD_MEM_IN, I_O_MEM_IN,
								       DST1_DEC_OUT, DST2_DEC_OUT, DST1_EX_IN, DST2_EX_IN, DST1_MEM_IN, DST2_MEM_IN,
								       Op1_MEM_IN, Op2_MEM_IN, Fetch_Forwarding_Stall, P_TAKEN_FETCH, False_Prediction_FETCH,
								       PC_KEY_FETCH, PC_Transparent, IR_FETCH);

---------------------------------------------- Fetch/Decode Buffer -----------------------------------------------------
FETCH_DC_BUFFER : ENTITY work.FETCH_DC_BUFFER PORT MAP (CLK, RST OR (Fetch_Forwarding_Stall OR PCWB_Stall OR False_Prediction_FETCH), 
					               (NOT EX_Forwarding_Stall), (EX_Forwarding_Stall NOR ((NOT IR_FETCH(0)) AND IR_FETCH(1))),  
        				  	       P_TAKEN_FETCH, P_TAKEN_DEC_IN, PC_KEY_FETCH, PC_KEY_DEC_IN,
	    				               IR_FETCH, IR_HIGH_DEC_IN, IR_LOW_DEC_IN);

---------------------------------------------- Decode Stage -------------------------------------------------------------
Decode_Stage : ENTITY work.Decode_Stage PORT MAP (CLK, RST, IR_HIGH_DEC_IN, IR_LOW_DEC_IN, (NOT EX_Forwarding_Stall),  
	        		   		  PC_Transparent, Flags, Op1_DEC_OUT, Op2_DEC_OUT, ALU_OP_DEC_OUT,
				   		  FLAGS_UPD_DEC_OUT, WB1_DEC_OUT, WB2_DEC_OUT, WR_DEC_OUT, RD_DEC_OUT,
				   		  I_O_DEC_OUT, PCWB_DEC_OUT, FLAGSWB_DEC_OUT, SRC1_DEC_OUT, SRC2_DEC_OUT,
	        		   		  IS_SRC1_DEC_OUT, IS_SRC2_DEC_OUT, DST1_DEC_OUT, DST2_DEC_OUT, JZ_DEC_OUT,  
	        		   		  WB1_WB, WB2_WB, DST1_WB, DST2_WB, Op1_WB, Op2_WB, IR_FETCH(7 TO 9), Port3_DEC_OUT);

---------------------------------------------- Decode/Execute Buffer ------------------------------------------------------
DC_EX_BUFFER : ENTITY work.DC_EX_BUFFER PORT MAP (CLK, RST, (NOT EX_Forwarding_Stall),                                     						
        	 		    Op1_DEC_OUT, Op2_DEC_OUT, ALU_OP_DEC_OUT, SRC1_DEC_OUT, SRC2_DEC_OUT, DST1_DEC_OUT, DST2_DEC_OUT,                            						    
        			    WB1_DEC_OUT, WB2_DEC_OUT, WR_DEC_OUT, RD_DEC_OUT, I_O_DEC_OUT, PCWB_DEC_OUT, FLAGSWB_DEC_OUT,
				    FLAGS_UPD_DEC_OUT, IS_SRC1_DEC_OUT, IS_SRC2_DEC_OUT, Op1_EX_IN, Op2_EX_IN, 
				    ALU_Op_EX_IN, SRC1_EX_IN, SRC2_EX_IN, DST1_EX_IN, DST2_EX_IN, WB1_EX_IN, 
				    WB2_EX_IN, WR_EX_IN, RD_EX_IN, I_O_EX_IN, PCWB_EX_IN, FLAGSWB_EX_IN, 
				    FLAGS_UPD_EX_IN, IS_SRC1_EX_IN, IS_SRC2_EX_IN);

---------------------------------------------- Execute Stage ---------------------------------------------------------------
Execute_Stage : ENTITY work.Execute_Stage 
				   GENERIC MAP (w_Mode)
				   PORT MAP (CLK, RST, Op1_EX_IN, Op2_EX_IN, ALU_Op_EX_IN, SRC1_EX_IN, SRC2_EX_IN, DST1_EX_IN, DST2_EX_IN,              	        	
				   WB1_EX_IN, WB2_EX_IN, WR_EX_IN, RD_EX_IN, I_O_EX_IN, PCWB_EX_IN, FLAGSWB_EX_IN, 
				   FLAGS_UPD_EX_IN, IS_SRC1_EX_IN, IS_SRC2_EX_IN, WB1_MEM_IN, WB2_MEM_IN, RD_MEM_IN, 
				   I_O_MEM_IN, DST1_MEM_IN, DST2_MEM_IN, Op1_MEM_IN, Op2_MEM_IN, WB1_WB, WB2_WB, FLAGSWB_WB,	 			
				   DST1_WB, DST2_WB, Op1_WB, Op2_WB, Input_Port, 
				   Op1_EX_OUT, Op2_EX_OUT, DST1_EX_OUT, DST2_EX_OUT, WB1_EX_OUT, 
				   WB2_EX_OUT, WR_EX_OUT, RD_EX_OUT, I_O_EX_OUT, PCWB_EX_OUT, FLAGSWB_EX_OUT, 
				   EX_Forwarding_Stall, Flags);

---------------------------------------------- Execute/Memory Buffer ----------------------------------------------------------	
EX_MEM_BUFFER : ENTITY work.EX_MEM_BUFFER PORT MAP (CLK, (RST OR EX_Forwarding_Stall), '1', Op1_EX_OUT, Op2_EX_OUT, DST1_EX_OUT, DST2_EX_OUT,                             			
        			      WB1_EX_OUT, WB2_EX_OUT, WR_EX_OUT, RD_EX_OUT, I_O_EX_OUT, PCWB_EX_OUT, FLAGSWB_EX_OUT, 
				      Op1_MEM_IN, Op2_MEM_IN, DST1_MEM_IN, DST2_MEM_IN, WB1_MEM_IN, WB2_MEM_IN, 
				      WR_MEM_IN, RD_MEM_IN, I_O_MEM_IN, PCWB_MEM_IN, FLAGSWB_MEM_IN);

---------------------------------------------- Memory Stage ---------------------------------------------------------------------
Memory_Stage : ENTITY work.Memory_Stage PORT MAP (CLK, RST, Op1_MEM_IN, Op2_MEM_IN, DST1_MEM_IN, DST2_MEM_IN, WB1_MEM_IN, WB2_MEM_IN, 
				    WR_MEM_IN, RD_MEM_IN, I_O_MEM_IN, PCWB_MEM_IN, FLAGSWB_MEM_IN, Op1_MEM_OUT, Op2_MEM_OUT,                  		
       	 			    DST1_MEM_OUT, DST2_MEM_OUT, WB1_MEM_OUT, WB2_MEM_OUT, PCWB_MEM_OUT, FLAGSWB_MEM_OUT, Output_Port); 

---------------------------------------------- Memory/Write Back Buffer ----------------------------------------------------------			 				
MEM_WB_BUFFER : ENTITY work.MEM_WB_BUFFER PORT MAP (CLK, RST, '1', Op1_MEM_OUT, Op2_MEM_OUT, DST1_MEM_OUT, DST2_MEM_OUT, 
			            WB1_MEM_OUT, WB2_MEM_OUT, PCWB_MEM_OUT, FLAGSWB_MEM_OUT, Op1_WB, Op2_WB, 
				    DST1_WB, DST2_WB, WB1_WB, WB2_WB, PCWB_WB, FLAGSWB_WB);  	

----------------------------------------------------------------------------------------------------------------------------------
END CPU_Arch;
