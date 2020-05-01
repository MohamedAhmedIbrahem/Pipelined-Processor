LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DATA_RAM IS
    GENERIC(CellSize: INTEGER := 16; AddressWidth: INTEGER := 32);
    PORT(
        CLK             : IN  STD_LOGIC;
        WR              : IN  STD_LOGIC;
    	RST		: IN  STD_LOGIC;
        Address         : IN  STD_LOGIC_VECTOR(AddressWidth-1 DOWNTO 0);
        Din             : IN  STD_LOGIC_VECTOR(2*CellSize-1 DOWNTO 0);
        Dout            : OUT STD_LOGIC_VECTOR(2*CellSize-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_DATA_RAM OF DATA_RAM IS
    CONSTANT MEMORY_SIZE: integer := 2000;
    TYPE memory IS ARRAY(0 TO MEMORY_SIZE-1) OF STD_LOGIC_VECTOR(CellSize-1 DOWNTO 0);
    SIGNAL Mem : memory := (OTHERS => (OTHERS => '0'));
BEGIN
    PROCESS(CLK,RST)
    BEGIN
		IF RST = '1' THEN
			Mem <= (OTHERS => (OTHERS => '0'));
		END IF;
        IF RISING_EDGE(CLK) and RST = '0' THEN
            IF WR='1' THEN
                Mem(TO_INTEGER(UNSIGNED(Address))) <= Din(2*CellSize-1 DOWNTO CellSize);
                Mem(TO_INTEGER(UNSIGNED(Address)) + 1) <= Din(CellSize-1 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;
    Dout <= Mem(TO_INTEGER(UNSIGNED(Address))) & Mem(TO_INTEGER(UNSIGNED(Address) + 1));
END ARCHITECTURE arch_DATA_RAM;