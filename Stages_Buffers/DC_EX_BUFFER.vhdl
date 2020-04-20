LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY DC_EX_BUFFER IS
    PORT(
        CLK, RST, EN                                    											: IN   STD_LOGIC;
        Op2,Op1                                         											: IN   STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
        ALU_Op                                          											: IN   STD_LOGIC_VECTOR(3 DOWNTO 0) ;    -- ALU operation
        SRC1,SRC2,DST1,DST2                             											: IN   STD_LOGIC_VECTOR(2 DOWNTO 0) ;    -- Registers' Adresses
        WB1,WB2,WR,RD,I_O,PCWB,FLAGSWB,FLAGS_UPD,IS_SRC1,IS_SRC2  									: IN   STD_LOGIC					;    -- Signals
        Op2_EX,Op1_EX                                         										: OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
        ALU_Op_EX                                          											: OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) ;    -- ALU operation
        SRC1_EX,SRC2_EX,DST1_EX,DST2_EX                             								: OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) ;    -- Registers' Adresses
        WB1_EX,WB2_EX,WR_EX,RD_EX,I_O_EX,PCWB_EX,FLAGSWB_EX,FLAGS_UPD_EX,IS_SRC1_EX,IS_SRC2_EX  	: OUT  STD_LOGIC                         -- Signals
    );
END ENTITY;

ARCHITECTURE arch OF DC_EX_BUFFER IS
COMPONENT RISING_EDGE_REG IS
    GENERIC(Size: INTEGER := 32);
    PORT(
        CLK, RST, EN    : IN  STD_LOGIC;
        Din             : IN  STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
        Dout            : OUT STD_LOGIC_VECTOR(Size-1 DOWNTO 0)
    );
END COMPONENT;
BEGIN
    U1  : RISING_EDGE_REG GENERIC MAP (32) PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => Op2 	 , Dout => Op2_EX)	  ;
	U2  : RISING_EDGE_REG GENERIC MAP (32) PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => Op1 	 , Dout => Op1_EX)    ;
	ALU : RISING_EDGE_REG GENERIC MAP (4)  PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => ALU_Op  , Dout => ALU_Op_EX) ;
	SR1 : RISING_EDGE_REG GENERIC MAP (3)  PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => SRC1 	 , Dout => SRC1_EX)	  ;
	SR2 : RISING_EDGE_REG GENERIC MAP (3)  PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => SRC2 	 , Dout => SRC2_EX)	  ;
	DS1 : RISING_EDGE_REG GENERIC MAP (3)  PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => DST1 	 , Dout => DST1_EX)	  ; 
	DS2 : RISING_EDGE_REG GENERIC MAP (3)  PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => DST2 	 , Dout => DST2_EX)	  ;
	PROCESS(CLK, RST)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF RST='1' THEN
                WB1_EX 		<= '0';
				WB2_EX 		<= '0';
				WR_EX		<= '0';
				RD_EX 		<= '0';
				I_O_EX 		<= '0';
				PCWB_EX 	<= '0';
				FLAGSWB_EX 	<= '0';
				IS_SRC1_EX 	<= '0';
				IS_SRC2_EX 	<= '0';
				FLAGS_UPD_EX<= '0';
            ELSIF EN='1' THEN
                WB1_EX 		<= WB1;
				WB2_EX 		<= WB2;
				WR_EX		<= WR ;
				RD_EX 		<= RD ;
				I_O_EX 		<= I_O;
				PCWB_EX 	<= PCWB;
				FLAGSWB_EX 	<= FLAGSWB;
				IS_SRC1_EX 	<= IS_SRC1;
				IS_SRC2_EX 	<= IS_SRC2;
				FLAGS_UPD_EX<= FLAGS_UPD;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;