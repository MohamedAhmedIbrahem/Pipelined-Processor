LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY branch_predictor IS
    GENERIC (PREDICTION_CACHE_KEY_SIZE : integer := 4);
    PORT (
        clk, rst, jz_decode, z_forwarded : IN std_logic;
        cache_key_fetch, cache_key_decode: IN std_logic_vector(PREDICTION_CACHE_KEY_SIZE-1 DOWNTO 0);
        predicted_taken, false_prediction: OUT std_logic
    );
END;

ARCHITECTURE branch_predictor_arch OF branch_predictor is
    SIGNAL is_taken: std_logic;
BEGIN
    prediction_cache: ENTITY work.branch_prediction_cache
        GENERIC MAP(PREDICTION_CACHE_KEY_SIZE => PREDICTION_CACHE_KEY_SIZE)
        PORT MAP(clk, rst, jz_decode, is_taken, cache_key_decode, cache_key_fetch, predicted_taken);

    prediction_corrector: ENTITY work.branch_prediction_corrector
        PORT MAP(predicted_taken, jz_decode, z_forwarded, is_taken, false_prediction);
END;