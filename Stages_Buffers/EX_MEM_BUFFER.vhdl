LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY EX_MEM_BUFFER IS
    PORT(
		CLK, RST, EN                                    				: IN   STD_LOGIC;
        Op2,Op1                                         				: IN   STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
        DST1,DST2                             							: IN   STD_LOGIC_VECTOR(2 DOWNTO 0);     -- Registers' Adresses
        WB1,WB2,WR,RD,I_O,PCWB,FLAGSWB  								: IN   STD_LOGIC;                        -- Signals
        Op2_MEM,Op1_MEM                                         		: OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
        DST1_MEM,DST2_MEM                             					: OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);     -- Registers' Adresses
        WB1_MEM,WB2_MEM,WR_MEM,RD_MEM,I_O_MEM,PCWB_MEM,FLAGSWB_MEM  	: OUT  STD_LOGIC                         -- Signals
    );
END ENTITY;

ARCHITECTURE arch OF EX_MEM_BUFFER IS
COMPONENT RISING_EDGE_REG IS
    GENERIC(Size: INTEGER := 32);
    PORT(
        CLK, RST, EN    : IN  STD_LOGIC;
        Din             : IN  STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
        Dout            : OUT STD_LOGIC_VECTOR(Size-1 DOWNTO 0)
    );
END COMPONENT;
BEGIN
    U1  : RISING_EDGE_REG GENERIC MAP (32) PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => Op2 	 , Dout => Op2_MEM)	   ;
	U2  : RISING_EDGE_REG GENERIC MAP (32) PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => Op1 	 , Dout => Op1_MEM)	   ;
	DS1 : RISING_EDGE_REG GENERIC MAP (3)  PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => DST1 	 , Dout => DST1_MEM)   ;
	DS2 : RISING_EDGE_REG GENERIC MAP (3)  PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => DST2 	 , Dout => DST2_MEM)   ;
	PROCESS(CLK, RST)
    BEGIN
        IF RISING_EDGE(CLK) THEN 
            IF RST='1' THEN
                WB1_MEM 	<= '0';
				WB2_MEM 	<= '0';
				WR_MEM		<= '0';
				RD_MEM 		<= '0';
				I_O_MEM 	<= '0';
				PCWB_MEM 	<= '0';
				FLAGSWB_MEM <= '0';
            ELSIF EN='1' THEN
                WB1_MEM 	<= WB1;
				WB2_MEM 	<= WB2;
				WR_MEM		<= WR ;
				RD_MEM 		<= RD ;
				I_O_MEM 	<= I_O;
				PCWB_MEM 	<= PCWB;
				FLAGSWB_MEM <= FLAGSWB;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;