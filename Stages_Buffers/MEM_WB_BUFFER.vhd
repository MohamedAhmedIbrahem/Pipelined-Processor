LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MEM_WB_BUFFER IS
    PORT(
		CLK, RST, EN                            : IN   STD_LOGIC					 ;
        Op1,Op2                                 : IN   STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
        DST1,DST2                             	: IN   STD_LOGIC_VECTOR(0 TO 2);    -- Registers' Adresses
        WB1,WB2,PCWB,FLAGSWB  					: IN   STD_LOGIC					 ;    -- Signals
        Op1_WB,Op2_WB                           : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
        DST1_WB,DST2_WB                         : OUT  STD_LOGIC_VECTOR(0 TO 2);    -- Registers' Adresses
        WB1_WB,WB2_WB,PCWB_WB,FLAGSWB_WB  		: OUT  STD_LOGIC					      -- Signals
    );
END ENTITY;

ARCHITECTURE arch OF MEM_WB_BUFFER IS
COMPONENT RISING_EDGE_REG IS
    GENERIC(Size: INTEGER := 32);
    PORT(
        CLK, RST, EN    : IN  STD_LOGIC;
        Din             : IN  STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
        Dout            : OUT STD_LOGIC_VECTOR(Size-1 DOWNTO 0)
    );
END COMPONENT;
BEGIN
    U1  : RISING_EDGE_REG GENERIC MAP (32) PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => Op2 	 , Dout => Op2_WB)	  ;
	U2  : RISING_EDGE_REG GENERIC MAP (32) PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => Op1 	 , Dout => Op1_WB)	  ;
	DS1 : RISING_EDGE_REG GENERIC MAP (3)  PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => DST1 	 , Dout => DST1_WB)   ;
	DS2 : RISING_EDGE_REG GENERIC MAP (3)  PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => DST2 	 , Dout => DST2_WB)   ;
	PROCESS(CLK, RST)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF RST='1' THEN
                WB1_WB 		<= '0';
				WB2_WB 		<= '0';
				PCWB_WB 	<= '0';
				FLAGSWB_WB  <= '0';
            ELSIF EN='1' THEN
                WB1_WB 		<= WB1;
				WB2_WB 		<= WB2;
				PCWB_WB 	<= PCWB;
				FLAGSWB_WB  <= FLAGSWB;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;