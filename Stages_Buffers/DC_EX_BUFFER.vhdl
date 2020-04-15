LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY DC_EX_BUFFER IS
    GENERIC(Size: INTEGER := 89);
    PORT(
        CLK, RST, EN                                    : IN  STD_LOGIC;
        Op2,Op1                                         : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);    -- operands
        ALU_Op                                          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);     -- ALU operation
        SRC1,SRC2,DST1,DST2                             : IN STD_LOGIC_VECTOR(2 DOWNTO 0);      -- Registers' Adresses
        WB1,WB2,WR,RD,I_O,PCWB,FLAGSWB,IS_SRC1,IS_SRC2  : IN STD_LOGIC;                         -- Signals
        Dout                                            : OUT STD_LOGIC_VECTOR(Size-1 DOWNTO 0) -- Whole output as one Register
    );
END ENTITY;

ARCHITECTURE arch OF DC_EX_BUFFER IS
SIGNAL Din : STD_LOGIC_VECTOR(Size - 1 DOWNTO 0);
BEGIN
    Din <= Op2 & Op1 & ALU_Op & WB1 & WB2 & WR & RD & I_O & PCWB & FLAGSWB & SRC1 & SRC2 & IS_SRC1 & IS_SRC2 & DST1 & DST2;
    REG : ENTITY work.RISING_EDGE_REG GENERIC MAP (Size) PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => Din , Dout => Dout);
END ARCHITECTURE;