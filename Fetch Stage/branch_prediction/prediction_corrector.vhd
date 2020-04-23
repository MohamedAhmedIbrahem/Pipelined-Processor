LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY branch_prediction_corrector IS
    PORT (
        predicted_taken, jz_decode, z_forwarded: IN std_logic;
        is_taken, false_prediction: OUT std_logic
    );
END;

ARCHITECTURE branch_prediction_corrector_arch OF branch_prediction_corrector is
BEGIN
    is_taken <= jz_decode and z_forwarded;
    false_prediction <= (is_taken xor predicted_taken) and jz_decode;
END;