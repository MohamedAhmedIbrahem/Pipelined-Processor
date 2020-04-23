LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;


ENTITY instruction_memory IS
    GENERIC(WORD_SIZE: INTEGER := 16; ADDRESS_SIZE: INTEGER := 32);
    PORT(
        clk, rst, write_enable : IN  STD_LOGIC;
        read_address, write_address : IN  STD_LOGIC_VECTOR(ADDRESS_SIZE-1 DOWNTO 0);
        data_in : IN  STD_LOGIC_VECTOR(0 TO WORD_SIZE-1);
        data_out : OUT STD_LOGIC_VECTOR(0 TO WORD_SIZE-1)
    );
END ENTITY;

ARCHITECTURE instruction_memory_arch OF instruction_memory IS
    CONSTANT MEMORY_SIZE: integer := 1000;
    TYPE memory_type IS ARRAY(0 TO MEMORY_SIZE-1) OF STD_LOGIC_VECTOR(WORD_SIZE-1 DOWNTO 0);
    SIGNAL memory : memory_type := (OTHERS => (OTHERS => '0'));
BEGIN
    PROCESS(clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (rst = '1') THEN
                memory <= (OTHERS => (OTHERS => '0'));
            ELSIF (write_enable ='1') THEN
                memory(to_integer(unsigned(write_address))) <= data_in;
            END IF;
        END IF;
    END PROCESS;

    data_out <= memory(to_integer(unsigned(read_address)));
END ARCHITECTURE;