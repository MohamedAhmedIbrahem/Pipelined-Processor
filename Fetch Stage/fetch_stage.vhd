LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY fetch_stage IS
    GENERIC (INSTRUCTION_WORD_SIZE: integer := 16; 
            ADDRESS_SIZE: integer := 32;
            PREDICTION_CACHE_KEY_SIZE: integer := 4
    );
    PORT (
        clk, rst, pc_enable, int_external, pc_write_back, predicted_taken_decode,
        jz_decode, z_forwarded, bubble_pc_write_back: IN std_logic;
        register_read_port3, pc_write_back_data : IN std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
        prediction_cache_key_decode: IN std_logic_vector(PREDICTION_CACHE_KEY_SIZE-1 DOWNTO 0);
        -- Forwarding unit signals BEGIN
        WB1_DEC, WB2_DEC, WB1_EX, WB2_EX, WB1_MEM, WB2_MEM, RD_MEM, I_O_MEM : IN std_logic;
        DST1_DEC, DST2_DEC, DST1_EX, DST2_EX, DST1_MEM, DST2_MEM : IN std_logic_vector(0 TO 2);
        Op1_MEM, Op2_MEM : IN std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
        Fetch_Forwarding_Stall: OUT std_logic;
        -- Forwarding unit signals END
        predicted_taken, false_prediction: OUT std_logic;
        prediction_cache_key: OUT std_logic_vector(PREDICTION_CACHE_KEY_SIZE-1 DOWNTO 0);
        pc_transparent_out: OUT std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
        instruction_memory_out: IN std_logic_vector(0 TO INSTRUCTION_WORD_SIZE-1);
        ir_fetch : OUT std_logic_vector(0 TO INSTRUCTION_WORD_SIZE-1);
        pc_out : OUT std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
        instruction_read: OUT std_logic
    );
END;

ARCHITECTURE fetch_stage_arch OF fetch_stage IS
    -- Internal instructions addresses addresses --
    CONSTANT INT1_ADDRESS : std_logic_vector := "10000000000000000000000000000000";
    CONSTANT RET_ADDRESS: std_logic_vector := "10000000000000000000000000000100";
    CONSTANT RST_ADDRESS: std_logic_vector := "10000000000000000000000000000101";

    TYPE ROM IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(INSTRUCTION_WORD_SIZE-1 DOWNTO 0);
    SIGNAL internal_instructions : ROM := (
        0 => "0000011000000000",
        1 => "0000111000000000",
        2 => "1000000000000010",
        3 => "0101111000000000",
        4 => "0001101000000000",
        5 => "1000000000000000",
        6 => "0110000000000000",
        OTHERS => (OTHERS => '0')
    );

    SIGNAL pc_in, pc_transparent_in, forwarded_jmp_value, jmp_register : std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
        
    SIGNAL int_internal, jz_fetch, jmp_fetch, int1_fetch, int2_fetch, rti_fetch, ret_fetch, is_two_word, is_int_executing, Fetch_Forwarding_Enable: std_logic;
    SIGNAL pc_incremented : std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
    SIGNAL op_code: std_logic_vector(0 TO 4);
BEGIN
    instruction_read <= not pc_out(31);

    ir_fetch <= instruction_memory_out WHEN instruction_read = '1' ELSE 
                internal_instructions(to_integer(unsigned(pc_out(2 DOWNTO 0))));

    pc_transparent_in <= jmp_register WHEN (jz_fetch = '1' and predicted_taken = '0') 
                                      ELSE pc_incremented;

    pc_incremented <= std_logic_vector(unsigned(pc_out) + 1);

    op_code <= ir_fetch(2 TO 6);


    branch_decoder: ENTITY work.branch_decoder 
        PORT MAP (op_code, jmp_fetch, jz_fetch, int1_fetch, int2_fetch, rti_fetch, ret_fetch);   
    
    prediction_cache_key <= pc_out(PREDICTION_CACHE_KEY_SIZE-1 DOWNTO 0);

    is_two_word <= ir_fetch(0);

    is_int_executing <= int1_fetch or int2_fetch;

    jmp_register <= forwarded_jmp_value WHEN Fetch_Forwarding_Enable = '1' ELSE register_read_port3;

    pc : ENTITY work.pc_register GENERIC MAP (ADDRESS_SIZE => ADDRESS_SIZE)
        PORT MAP(clk, rst, pc_enable, pc_in, RST_ADDRESS, pc_out);

    pc_transparent : ENTITY work.RISING_EDGE_REG GENERIC MAP (SIZE => ADDRESS_SIZE)
        PORT MAP(clk, rst, not int1_fetch, pc_transparent_in, pc_transparent_out);

    pc_controller : ENTITY work.pc_controller GENERIC MAP(ADDRESS_SIZE => ADDRESS_SIZE)
        PORT MAP(
            int_internal, pc_write_back, jz_fetch, jmp_fetch, rti_fetch, predicted_taken, 
            false_prediction, pc_incremented, INT1_ADDRESS, RET_ADDRESS, jmp_register,
            pc_write_back_data, pc_transparent_out, pc_in
        );

    branch_predictor : ENTITY work.branch_predictor
        GENERIC MAP(PREDICTION_CACHE_KEY_SIZE => PREDICTION_CACHE_KEY_SIZE)
        PORT MAP(
            clk, rst, jz_decode, z_forwarded, predicted_taken_decode, prediction_cache_key, 
            prediction_cache_key_decode, predicted_taken, false_prediction
        );

    interrupt_controller : ENTITY work.interrupt_controller
        PORT MAP(
            clk, rst, int_external, jmp_fetch, jz_fetch, jz_decode, ret_fetch, rti_fetch,
            is_int_executing, bubble_pc_write_back, is_two_word, int_internal
        );

    fetch_forwarding_unit : ENTITY work.Fetch_Forwarding_Unit
        PORT MAP(
            rst, jz_fetch, jmp_fetch, ir_fetch(7 TO 9), WB1_DEC, WB2_DEC, DST1_DEC, DST2_DEC,
            WB1_EX, WB2_EX, DST1_EX, DST2_EX, WB1_MEM, WB2_MEM, RD_MEM, I_O_MEM, DST1_MEM, DST2_MEM,
		    Op1_MEM, Op2_MEM, Fetch_Forwarding_Enable, Fetch_Forwarding_Stall, forwarded_jmp_value	
        );
END;