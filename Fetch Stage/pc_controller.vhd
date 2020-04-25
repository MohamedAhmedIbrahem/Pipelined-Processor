LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY pc_controller IS
    GENERIC (ADDRESS_SIZE: integer := 32);
    PORT (
        is_int_internal, pc_write_back, is_jz, is_jmp, predicted_taken, 
            false_prediction: IN std_logic;
        pc_incremented, int1_address, jmp_register, pc_write_back_data, 
            pc_transparent: IN std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
        new_pc: OUT std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0)
    );
END;

ARCHITECTURE pc_controller_arch OF pc_controller IS
BEGIN
    PROCESS (ALL)
    BEGIN
        IF (is_int_internal = '1') THEN
            new_pc <= int1_address;
        ELSIF (pc_write_back = '1') THEN
            new_pc <= pc_write_back_data;
        ELSIF (false_prediction = '1') THEN
            new_pc <= pc_transparent;
        ELSIF (is_jmp = '1' or (is_jz = '1' and predicted_taken = '1')) THEN
            new_pc <= jmp_register;
        ELSE
            new_pc <= pc_incremented;
        END IF;
    END PROCESS;
END;