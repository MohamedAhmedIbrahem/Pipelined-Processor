LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY branch_decoder IS
    PORT (
        op_code: IN std_logic_vector(0 TO 4);
        is_jmp, is_jz: OUT std_logic
    );
END;

ARCHITECTURE branch_decoder_arch OF branch_decoder is
    CONSTANT JMP_OP_CODE: std_logic_vector := "11100";
    CONSTANT JZ_OP_CODE: std_logic_vector := "11001";
    CONSTANT CALL_OP_CODE: std_logic_vector := "11110";
    CONSTANT RTI_OP_CODE: std_logic_vector := "01110";
BEGIN
    is_jmp <= '1' WHEN op_code = JMP_OP_CODE or 
                       op_code = CALL_OP_CODE or 
                       op_code = RTI_OP_CODE
                 ELSE '0';

    is_jz <= '1' WHEN op_code = JZ_OP_CODE ELSE '0';
END;