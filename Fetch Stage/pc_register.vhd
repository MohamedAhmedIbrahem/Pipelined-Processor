LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY pc_register IS
    GENERIC(ADDRESS_SIZE: INTEGER := 32);
    PORT(
        clk, rst, enable    : IN  STD_LOGIC;
        data_in             : IN  STD_LOGIC_VECTOR(ADDRESS_SIZE-1 DOWNTO 0);
        reset_data          : IN std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
        data_out            : OUT STD_LOGIC_VECTOR(ADDRESS_SIZE-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE pc_register_arch OF pc_register IS
BEGIN
    PROCESS(clk)
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst ='1' THEN
                data_out <= reset_data;
            ELSIF enable ='1' THEN
                data_out <= data_in;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;