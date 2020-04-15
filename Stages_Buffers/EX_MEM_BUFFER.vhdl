LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY EX_MEM_BUFFER IS
    GENERIC(Size: INTEGER := 77);
    PORT(
        CLK, RST, EN                   : IN  STD_LOGIC;
        Op2,Op1                        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
        DST1,DST2                      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);      -- Registers' Adresses
        WB1,WB2,WR,RD,I_O,PCWB,FLAGSWB : IN STD_LOGIC;                         -- Signals
        Dout                           : OUT STD_LOGIC_VECTOR(Size-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch OF EX_MEM_BUFFER IS
SIGNAL Din : STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
BEGIN
    Din <= Op2 & Op1 & WB1 & WB2 & WR & RD & I_O & PCWB & FLAGSWB & DST1 & DST2;
    REG : ENTITY work.RISING_EDGE_REG GENERIC MAP (Size) PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => Din , Dout => Dout);
END ARCHITECTURE;