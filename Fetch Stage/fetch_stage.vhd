LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY fetch_stage IS
    GENERIC (INSTRUCTION_WORD_SIZE: integer := 16; 
            ADDRESS_SIZE: integer := 32;
            PREDICTION_CACHE_KEY_SIZE: integer := 4
    );
    PORT (
        clk, rst, pc_enable, is_rst, is_int, pc_write_back: IN std_logic;
        jmp_register, pc_write_back_data : IN std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
        predicted_taken: OUT std_logic;
        prediction_cache_key: OUT std_logic_vector(PREDICTION_CACHE_KEY_SIZE-1 DOWNTO 0);
        ir_fetch : OUT std_logic_vector(0 TO INSTRUCTION_WORD_SIZE-1)
    );
END;

ARCHITECTURE fetch_stage_arch OF fetch_stage IS
    -- Constant JUMP addresses --
    CONSTANT INT1_ADDRESS : std_logic_vector := std_logic_vector(to_unsigned(500, ADDRESS_SIZE));
    CONSTANT RST_ADDRESS: std_logic_vector := std_logic_vector(to_unsigned(499, ADDRESS_SIZE));
    CONSTANT RTI2_ADDRESS: std_logic_vector := std_logic_vector(to_unsigned(498, ADDRESS_SIZE));

    -- OP Codes for branch decoder --
    CONSTANT JMP_OP_CODE: std_logic_vector := "11100";
    CONSTANT JZ_OP_CODE: std_logic_vector := "11001";
    CONSTANT CALL_OP_CODE: std_logic_vector := "11110";
    CONSTANT RTI_OP_CODE: std_logic_vector := "01110";

    SIGNAL pc_in, pc_out, pc_transparent_in, pc_transparent_out: 
        std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
    SIGNAL is_int_internal, is_jz, is_jmp, false_prediction: std_logic;
    SIGNAL pc_incremented : std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
    
BEGIN
    -- Temporary until dynamic branch prediction and interrupt controller are implemented
    predicted_taken <= '1';
    false_prediction <= '0';
    is_int_internal <= '0';

    prediction_cache_key <= pc_out(PREDICTION_CACHE_KEY_SIZE-1 DOWNTO 0);

    pc_transparent_in <= jmp_register WHEN (is_jz = '1' and predicted_taken = '0') 
                                      ELSE pc_incremented;

    pc_incremented <= std_logic_vector(unsigned(pc_out) + 1);

    is_jmp <= '1' WHEN ir_fetch(2 TO 6) = JMP_OP_CODE or 
                       ir_fetch(2 TO 6) = CALL_OP_CODE or 
                       ir_fetch(2 TO 6) = RTI_OP_CODE
                  ELSE '0';

    is_jz <= '1' WHEN ir_fetch(2 TO 6) = JZ_OP_CODE ELSE '0';

    --ir_high <= ir_fetch WHEN ir_fetch(0) = '0' ELSE (OTHERS => '0');
    --ir_low <= ir_fetch WHEN ir_fetch(0) = '1' ELSE (OTHERS => '0');

    pc : ENTITY work.RISING_EDGE_REG GENERIC MAP (SIZE => ADDRESS_SIZE)
        PORT MAP(clk, rst, pc_enable, pc_in, pc_out);

    instruction_memory : ENTITY work.instruction_memory 
        GENERIC MAP (WORD_SIZE => INSTRUCTION_WORD_SIZE, ADDRESS_SIZE => ADDRESS_SIZE)
        PORT MAP(clk, rst, '0', pc_out, (OTHERS => 'Z'), (OTHERS => 'Z'), ir_fetch); 

    pc_transparent : ENTITY work.RISING_EDGE_REG GENERIC MAP (SIZE => ADDRESS_SIZE)
        PORT MAP(clk, rst, '1', pc_transparent_in, pc_transparent_out);

    pc_controller: ENTITY work.pc_controller GENERIC MAP(ADDRESS_SIZE => ADDRESS_SIZE)
        PORT MAP(
            is_int_internal, pc_write_back, is_rst, is_jz, is_jmp, predicted_taken, 
            false_prediction, pc_incremented, INT1_ADDRESS, RST_ADDRESS, jmp_register,
            pc_write_back_data, pc_transparent_out, pc_in
        );
END;