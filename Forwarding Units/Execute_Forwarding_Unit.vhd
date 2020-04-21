LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY Execute_Forwarding_Unit IS
	PORT (
		CLK, RST 					: IN STD_LOGIC;
		IS_SRC1_EX, IS_SRC2_EX 				: IN STD_LOGIC; 			-- Execute Stage Signals
		SRC1_EX, SRC2_EX				: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 	-- Execute Stage SRC Addresses
		WB1_MEM, WB2_MEM, RD_MEM, I_O_MEM 		: IN STD_LOGIC; 			-- Memory Stage Signals
		DST1_MEM, DST2_MEM 				: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 	-- Memory Stage DST Addresses
		Op1_MEM, Op2_MEM 				: IN STD_LOGIC_VECTOR(31 DOWNTO 0); 	-- Memory Stage DST Registers
		WB1_WB, WB2_WB 					: IN STD_LOGIC; 			-- Write Back Stage Signals
		DST1_WB, DST2_WB 				: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 	-- Write Back Stage DST Addresses
		Op1_WB, Op2_WB 					: IN STD_LOGIC_VECTOR(31 DOWNTO 0); 	-- Write Back Stage DST Registers
		Op1_EX_Forwarding_Enable, 
		Op2_EX_Forwarding_Enable, 
		EX_Forwarding_Stall 				: OUT STD_LOGIC; 			-- Forwarding Enables & Stall Signals
		Op1_EX_Forwarded, Op2_EX_Forwarded 		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 	-- The Forwarded Operands
	);
END ENTITY;

ARCHITECTURE Execute_Forwarding_Unit_Arch OF Execute_Forwarding_Unit IS
BEGIN
	PROCESS (CLK)
	BEGIN
		IF (RST = '1') THEN
			Op1_EX_Forwarding_Enable <= '0';
			Op2_EX_Forwarding_Enable <= '0';
			Op1_EX_Forwarded <= (OTHERS => '0');
			Op2_EX_Forwarded <= (OTHERS => '0');
			EX_Forwarding_Stall <= '0';
		ELSE
----------------------------------------- SRC 1 -----------------------------------------------------
			IF (IS_SRC1_EX = '1') AND 
			   (((WB1_MEM = '1') AND (SRC1_EX = DST1_MEM)) OR ((WB2_MEM = '1') AND (SRC1_EX = DST2_MEM))) THEN -- Memory Stage	

				IF (RD_MEM = '1') AND (I_O_MEM = '1') THEN -- Memory Instruction
					EX_Forwarding_Stall <= '1';
				ELSE -- ALU Instruction
					Op1_EX_Forwarding_Enable <= '1';
					IF (WB1_MEM = '1') THEN
						Op1_EX_Forwarded <= Op1_MEM;
					ELSIF (WB2_MEM = '1') THEN
						Op1_EX_Forwarded <= Op2_MEM;
					END IF;
				END IF;
			ELSIF (IS_SRC1_EX = '1') AND (((WB1_WB = '1') AND 
			      (SRC1_EX = DST1_WB)) OR ((WB2_WB = '1') AND (SRC1_EX = DST2_WB))) THEN -- Write Back Stage	
	
				Op1_EX_Forwarding_Enable <= '1';
				IF WB1_WB THEN
					Op1_EX_Forwarded <= Op1_WB;
				ELSIF WB2_WB THEN
					Op1_EX_Forwarded <= Op2_WB;
				END IF;
			END IF;
----------------------------------------- SRC 2 -----------------------------------------------------
			IF (IS_SRC2_EX = '1') AND (((WB1_MEM = '1') AND 
			   (SRC2_EX = DST1_MEM)) OR ((WB2_MEM = '1') AND (SRC2_EX = DST2_MEM))) THEN -- Memory Stage	

				IF (RD_MEM = '1') AND (I_O_MEM = '1') THEN
					EX_Forwarding_Stall <= '1';
				ELSE
					Op2_EX_Forwarding_Enable <= '1';
					IF (WB1_MEM = '1') THEN
						Op2_EX_Forwarded <= Op1_MEM;
					ELSIF (WB2_MEM = '1') THEN
						Op2_EX_Forwarded <= Op2_MEM;
					END IF;
				END IF;
			ELSIF (IS_SRC2_EX = '1') AND (((WB1_WB = '1') AND 
			      (SRC2_EX = DST1_WB)) OR ((WB2_WB = '1') AND (SRC2_EX = DST2_WB))) THEN -- Write Back Stage	

				Op2_EX_Forwarding_Enable <= '1';
				IF (WB1_WB = '1') THEN
					Op2_EX_Forwarded <= Op1_WB;
				ELSIF (WB2_WB = '1') THEN
					Op2_EX_Forwarded <= Op2_WB;
				END IF;
			END IF;
------------------------------------------------------------------------------------------------------------
		END IF;
	END PROCESS;
END ARCHITECTURE;