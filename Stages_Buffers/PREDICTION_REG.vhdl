LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY PREDICTION_REG IS
    PORT(
        CLK, RST, EN    : IN  STD_LOGIC;
        P_TAKEN         : IN  STD_LOGIC;
        PC_KEY          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        PC_K            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		P_TAKE 		: OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE arch OF PREDICTION_REG IS
COMPONENT RISING_EDGE_REG IS
    GENERIC(Size: INTEGER := 32);
    PORT(
        CLK, RST, EN    : IN  STD_LOGIC;
        Din             : IN  STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
        Dout            : OUT STD_LOGIC_VECTOR(Size-1 DOWNTO 0)
    );
END COMPONENT;
BEGIN
    REG : RISING_EDGE_REG GENERIC MAP (4) PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => PC_KEY , Dout => PC_K);
	PROCESS(CLK, RST)
    BEGIN
        IF RISING_EDGE(CLK) THEN 
            IF RST='1' THEN
                P_TAKE <= '0';
            ELSIF EN='1' THEN
                P_TAKE <= P_TAKEN;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;