LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY fetch_stage IS
    GENERIC (INSTRUCTION_WORD_SIZE: integer := 16; 
            ADDRESS_SIZE: integer := 32;
            PREDICTION_CACHE_KEY_SIZE: integer := 4
    );
    PORT (
        clk, rst, pc_enable, rst_external, int_external, pc_write_back, 
        jz_decode, z_forwarded, bubble_pc_write_back: IN std_logic;
        jmp_register, pc_write_back_data : IN std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
        prediction_cache_key_decode: IN std_logic_vector(PREDICTION_CACHE_KEY_SIZE-1 DOWNTO 0);
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

    SIGNAL pc_in, pc_out, pc_transparent_in, pc_transparent_out: 
        std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
    SIGNAL int_internal, jz_fetch, jmp_fetch, false_prediction, is_two_word, is_int_executing: std_logic;
    SIGNAL pc_incremented : std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
    SIGNAL op_code: std_logic_vector(0 TO 4);
BEGIN
    pc_transparent_in <= jmp_register WHEN (jz_fetch = '1' and predicted_taken = '0') 
                                      ELSE pc_incremented;

    pc_incremented <= std_logic_vector(unsigned(pc_out) + 1);

    op_code <= ir_fetch(2 TO 6);

    branch_decoder: ENTITY work.branch_decoder PORT MAP (op_code, jmp_fetch, jz_fetch);   
    
    prediction_cache_key <= pc_out(PREDICTION_CACHE_KEY_SIZE-1 DOWNTO 0);

    is_two_word <= ir_fetch(0);

    is_int_executing <= '1' WHEN pc_out = INT1_ADDRESS 
                              or pc_out = std_logic_vector(unsigned(INT1_ADDRESS) + 1)
                            ELSE '0';

    pc : ENTITY work.RISING_EDGE_REG GENERIC MAP (SIZE => ADDRESS_SIZE)
        PORT MAP(clk, rst, pc_enable, pc_in, pc_out);

    instruction_memory : ENTITY work.instruction_memory 
        GENERIC MAP (WORD_SIZE => INSTRUCTION_WORD_SIZE, ADDRESS_SIZE => ADDRESS_SIZE)
        PORT MAP(clk, rst, '0', pc_out, (OTHERS => 'Z'), (OTHERS => 'Z'), ir_fetch); 

    pc_transparent : ENTITY work.RISING_EDGE_REG GENERIC MAP (SIZE => ADDRESS_SIZE)
        PORT MAP(clk, rst, '1', pc_transparent_in, pc_transparent_out);

    pc_controller : ENTITY work.pc_controller GENERIC MAP(ADDRESS_SIZE => ADDRESS_SIZE)
        PORT MAP(
            int_internal, pc_write_back, rst_external, jz_fetch, jmp_fetch, predicted_taken, 
            false_prediction, pc_incremented, INT1_ADDRESS, RST_ADDRESS, jmp_register,
            pc_write_back_data, pc_transparent_out, pc_in
        );

    branch_predictor : ENTITY work.branch_predictor
        GENERIC MAP(PREDICTION_CACHE_KEY_SIZE => PREDICTION_CACHE_KEY_SIZE)
        PORT MAP(
            clk, rst, jz_decode, z_forwarded, prediction_cache_key, prediction_cache_key_decode,
            predicted_taken, false_prediction
        );

    interrupt_controller : ENTITY work.interrupt_controller
        PORT MAP(
            clk, rst, int_external, jmp_fetch, jz_fetch, jz_decode, is_int_executing, 
            bubble_pc_write_back, is_two_word, int_internal
        );
END;