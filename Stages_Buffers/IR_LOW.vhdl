LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY IR_LOW IS
    GENERIC(Size: INTEGER := 16);
    PORT(
        CLK, RST, EN    : IN  STD_LOGIC;
        Din             : IN  STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
        Dout            : OUT STD_LOGIC_VECTOR(Size-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch OF IR_LOW IS
BEGIN
    REG : ENTITY work.RISING_EDGE_REG GENERIC MAP (Size) PORT MAP (CLK => CLK , RST => RST , EN => EN , Din => Din , Dout => Dout);
END ARCHITECTURE;