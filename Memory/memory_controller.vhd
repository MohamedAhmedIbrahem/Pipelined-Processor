LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- TODO remove extra cycle on miss conflicts
ENTITY memory_controller IS
    PORT (
        clk, rst, data_write: IN std_logic;
        instruction_read, data_read: IN std_logic;
        instruction_address, data_address: IN std_logic_vector (10 DOWNTO 0);
        data_in: IN std_logic_vector (31 DOWNTO 0);
        data_out: OUT std_logic_vector (31 DOWNTO 0);
        instruction_out: OUT std_logic_vector (15 DOWNTO 0);
        data_ready, instruction_ready: OUT std_logic
    );
END;

ARCHITECTURE memory_controller_arch OF memory_controller IS
    type states is (
        IDLE, WRITE_DATA_BLOCK, READ_DATA_BLOCK, READ_CODE_BLOCK    
    );
    constant initial_state: states := IDLE;
    signal current_state: states := initial_state;
    signal instruction_block_write, data_block_write: std_logic;
    signal instruction_hit, instruction_dirty, instruction_valid: std_logic;
    signal data_hit, data_dirty, data_valid: std_logic;
    signal memory_write, memory_read, memory_done: std_logic;
    signal memory_address: std_logic_vector(10 DOWNTo 0);
    signal memory_data_in, memory_data_out : std_logic_vector(127 DOWNTO 0);
    signal start_read_data_block, start_read_code_block, start_write_data_block : std_logic;
    signal data_current_tag : std_logic_vector(2 DOWNTO 0);
BEGIN
    instruction_cache: ENTITY work.instruction_cache 
    PORT MAP (
        clk, rst, '0', instruction_address, (OTHERS => 'Z'), instruction_out,
        instruction_block_write, memory_address, memory_data_out,
        open, instruction_hit, instruction_valid, instruction_dirty
    );

    data_cache: ENTITY work.data_cache
    PORT MAP (
        clk, rst, data_write, data_address, data_in, data_out, data_block_write,
        memory_address, memory_data_out, memory_data_in, data_hit, data_valid, data_dirty, data_current_tag
    );

    main_memory: ENTITY work.RAM
    PORT MAP (
        clk, memory_write, memory_read, memory_address, memory_data_in, memory_done, memory_data_out 
    );

    start_read_data_block <= '1' WHEN (data_read = '1' or data_write = '1') and data_hit = '0' ELSE '0';
    start_read_code_block <= '1' WHEN instruction_read = '1' and instruction_hit = '0' ELSE '0';
    start_write_data_block <= '1' WHEN start_read_data_block = '1' and data_valid = '1' and data_dirty = '1'
                                  ELSE '0';

    data_block_write <= '1' WHEN current_state = READ_DATA_BLOCK and memory_done = '1' 
                            ELSE '0';
    instruction_block_write <= '1' WHEN current_state = READ_CODE_BLOCK and memory_done = '1' 
                                  ELSE '0';
    
    data_ready <= '1' WHEN current_state = IDLE and data_hit = '1' ELSE '0';
    instruction_ready <= '1' WHEN current_state = IDLE and instruction_hit = '1' ELSE '0';

    -- memory inputs process
    PROCESS (ALL)
    BEGIN
        memory_write <= '0';
        memory_read <= '0';
        memory_address <= (OTHERS => '0');
        IF current_state = IDLE and start_write_data_block = '1' THEN
            memory_write <= '1';
        ELSIF (current_state = IDLE and start_read_data_block = '1') or 
            (current_state = WRITE_DATA_BLOCK and memory_done = '1') THEN
            memory_read <= '1';
        ELSIF current_state = IDLE and start_read_code_block = '1' THEN
            memory_read <= '1';
        ELSIF current_state = WRITE_DATA_BLOCK THEN
            memory_address <= data_current_tag & data_address(7 DOWNTO 3) & "000";
        ELSIF current_state = READ_DATA_BLOCK THEN
            memory_address <= data_address(10 DOWNTO 3) & "000";
        ELSIF current_state = READ_CODE_BLOCK THEN
            memory_address <= instruction_address(10 DOWNTO 3) & "000";
        END IF;
    END PROCESS;

    -- FSM process
    PROCESS (clk, rst) 
    BEGIN
        IF rst = '1' THEN
            current_state <= initial_state;
        ELSIF rising_edge(clk) THEN 
            CASE current_state IS
                WHEN IDLE => 
                    IF start_write_data_block = '1' THEN
                        current_state <= WRITE_DATA_BLOCK;
                    ELSIF start_read_data_block = '1' THEN 
                        current_state <= READ_DATA_BLOCK;
                    ELSIF start_read_code_block = '1' THEN
                        current_state <= READ_CODE_BLOCK;
                    END IF;
                WHEN WRITE_DATA_BLOCK =>
                    IF memory_done = '1' THEN
                        current_state <= READ_DATA_BLOCK;
                    END IF;
                WHEN READ_DATA_BLOCK =>
                    IF memory_done = '1' THEN
                        current_state <= IDLE;
                    END IF;
                WHEN READ_CODE_BLOCK =>
                    IF memory_done = '1' THEN
                        current_state <= IDLE;
                    END IF;
            END CASE;
        END IF;
    END PROCESS;
END;