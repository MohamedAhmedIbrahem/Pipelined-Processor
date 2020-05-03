LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY interrupt_controller IS
    GENERIC (PREDICTION_CACHE_KEY_SIZE : integer := 4);
    PORT (
        clk, rst, int_external, is_jmp, is_jz, is_jz_decode, ret_fetch, rti_fetch, is_int_executing,
        bubble_pc_write_back, is_two_word: IN std_logic;
        int_internal: OUT std_logic
    );
END;

ARCHITECTURE interrupt_controller_arch OF interrupt_controller is
    SIGNAL hold_int, stored_int: std_logic;
BEGIN
    hold_int <= is_jmp or is_jz or is_jz_decode or bubble_pc_write_back or is_two_word or is_int_executing or ret_fetch or rti_fetch;
    int_internal <= '0' WHEN hold_int = '1' ELSE stored_int or int_external;
    PROCESS (clk)
    BEGIN
        IF(rising_edge(clk)) THEN
            IF (rst = '1' or hold_int = '0') THEN
                stored_int <= '0';
            ELSIF (hold_int = '1' and int_external = '1') THEN
                stored_int <= '1';
            END IF;
        END IF;
    END PROCESS;
END;
