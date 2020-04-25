LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY branch_prediction_cache IS
    GENERIC (PREDICTION_CACHE_KEY_SIZE : integer := 4);
    PORT (
        clk, rst, write_enable, is_taken: IN std_logic;
        write_address, read_address: IN std_logic_vector(PREDICTION_CACHE_KEY_SIZE-1 DOWNTO 0);
        predicted_taken: OUT std_logic
    );
END;

ARCHITECTURE branch_prediction_cache_arch OF branch_prediction_cache is
    CONSTANT CACHE_SIZE: integer := 2 ** PREDICTION_CACHE_KEY_SIZE;
    SIGNAL fsm_predicted_taken, fsm_enable: std_logic_vector(0 TO CACHE_SIZE-1);
BEGIN
    GENERATE_FSM:
    FOR i IN 0 TO CACHE_SIZE-1 GENERATE
        fsm_enable(i) <= '1' WHEN (to_integer(unsigned(write_address)) = i and write_enable = '1') 
                             ELSE '0';
        branch_prediction_fsm : ENTITY work.branch_prediction_fsm 
            PORT MAP (clk, rst, is_taken, fsm_enable(i), fsm_predicted_taken(i));
    END GENERATE;

    predicted_taken <= fsm_predicted_taken(to_integer(unsigned(read_address)));
END;
