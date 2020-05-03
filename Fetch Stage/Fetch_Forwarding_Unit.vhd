LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY Fetch_Forwarding_Unit IS
	PORT (
		RST 						: IN STD_LOGIC;
		JZ_Fetch, JMP_Fetch		 		: IN STD_LOGIC; 			-- Fetch Stage Signals
		SRC1_Fetch					: IN STD_LOGIC_VECTOR(0 TO 2);	      -- Fetch Stage SRC Address IR_Fetch[7:9]
		WB1_DEC, WB2_DEC				: IN STD_LOGIC; 			-- Decode Stage Signals
		DST1_DEC, DST2_DEC 				: IN STD_LOGIC_VECTOR(0 TO 2);	 	-- Decode Stage DST Addresses IR[7:9], IR[10:12]
		WB1_EX, WB2_EX 		 			: IN STD_LOGIC; 			-- Execute Stage Signals
		DST1_EX, DST2_EX 				: IN STD_LOGIC_VECTOR(0 TO 2);	 	-- Execute Stage DST Addresses
		WB1_MEM, WB2_MEM, RD_MEM, I_O_MEM 		: IN STD_LOGIC; 			-- Memory Stage Signals
		DST1_MEM, DST2_MEM 				: IN STD_LOGIC_VECTOR(0 TO 2);	 	-- Memory Stage DST Addresses
		Op1_MEM, Op2_MEM 				: IN STD_LOGIC_VECTOR(31 DOWNTO 0); 	-- Memory Stage DST Registers
		Fetch_Forwarding_Enable, 
		Fetch_Forwarding_Stall 				: OUT STD_LOGIC; 			-- Forwarding Enables & Stall Signals
		Op_Fetch_Forwarded		 		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 	-- The Forwarded Operand
	);
END ENTITY;

ARCHITECTURE Fetch_Forwarding_Unit_Arch OF Fetch_Forwarding_Unit IS
BEGIN
	PROCESS (ALL)
	BEGIN
		IF (RST = '1') THEN
			Fetch_Forwarding_Enable <= '0';
			Op_Fetch_Forwarded <= (OTHERS => '0');
			Fetch_Forwarding_Stall <= '0';
		ELSE
			Fetch_Forwarding_Enable <= '0';
			Fetch_Forwarding_Stall <= '0';
			IF (JZ_Fetch = '1' OR JMP_Fetch = '1') THEN       -- Instruction that Changes PC
				IF (((WB1_DEC = '1') AND (SRC1_Fetch = DST1_DEC)) OR	       -- Decode Stage
				    ((WB2_DEC = '1') AND (SRC1_Fetch = DST2_DEC)))   THEN 
					Fetch_Forwarding_Stall <= '1';

				ELSIF (((WB1_EX = '1') AND (SRC1_Fetch = DST1_EX)) OR		-- Execute Stage
				       ((WB2_EX = '1') AND (SRC1_Fetch = DST2_EX)))   THEN 
					Fetch_Forwarding_Stall <= '1';
		

				ELSIF (((WB1_MEM = '1') AND (SRC1_Fetch = DST1_MEM)) OR		-- Memory Stage
				       ((WB2_MEM = '1') AND (SRC1_Fetch = DST2_MEM)))   THEN 
					
					IF ((RD_MEM = '1') AND (I_O_MEM = '1')) THEN		-- Memory Instruction
						Fetch_Forwarding_Stall <= '1';
					ELSE
						Fetch_Forwarding_Enable <= '1';			-- ALU Instruction
						IF (WB1_MEM = '1' AND (SRC1_Fetch = DST1_MEM)) THEN
							Op_Fetch_Forwarded <= Op1_MEM;
						ELSIF (WB2_MEM = '1' AND (SRC1_Fetch = DST2_MEM)) THEN
							Op_Fetch_Forwarded <= Op2_MEM;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;
