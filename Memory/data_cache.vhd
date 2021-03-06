LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.math_real.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY data_cache IS
    GENERIC (
        word_size : INTEGER := 16;
        capacity_in_words : INTEGER := 256;
        words_number_in_block : INTEGER := 8;
        address_width : INTEGER := 11);
    PORT (
        clk : IN std_logic;
        rst : IN std_logic;
        wr : IN std_logic;
        address : IN std_logic_vector(address_width - 1 DOWNTO 0);
        data_in : IN std_logic_vector(2 * word_size - 1 DOWNTO 0);
        data_out : OUT std_logic_vector(2 * word_size - 1 DOWNTO 0);
        force_wr : IN std_logic;
        controller_address : IN std_logic_vector(address_width - 1 DOWNTO 0);
        controller_data_in : IN std_logic_vector(0 TO words_number_in_block * word_size - 1);
        controller_data_out : OUT std_logic_vector(0 TO words_number_in_block * word_size - 1);
        hit : OUT std_logic;
        valid : OUT std_logic;
        dirty : OUT std_logic;
        current_tag : OUT std_logic_vector(2 DOWNTO 0)
    );
END data_cache;

ARCHITECTURE data_cache_operation OF data_cache IS
    CONSTANT entries : INTEGER := capacity_in_words / words_number_in_block;
    CONSTANT word_offset_size : INTEGER := INTEGER(log2(real(words_number_in_block)));
    CONSTANT index_size : INTEGER := INTEGER(log2(real(entries)));
    CONSTANT tag_size : INTEGER := address_width - word_offset_size - index_size;
    TYPE words_in_block IS ARRAY(0 TO words_number_in_block - 1) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    TYPE entry IS RECORD
        tag : std_logic_vector(tag_size - 1 DOWNTO 0);
        valid : std_logic;
        dirty : std_logic;
        words : words_in_block;
    END RECORD entry;
    CONSTANT zero_entry : entry := (tag => (OTHERS => '0'), valid => '0', dirty => '0', words => (OTHERS => (OTHERS => '0')));
    TYPE cache_type IS ARRAY(0 TO entries - 1) OF entry;
    SIGNAL cache : cache_type;
    SIGNAL word_offset : INTEGER := 0;
    SIGNAL controller_index, index : INTEGER := 0;
    SIGNAL controller_tag, tag : std_logic_vector(tag_size - 1 DOWNTO 0);
BEGIN
    word_offset <= to_integer(unsigned(address(word_offset_size - 1 DOWNTO 0)));

    index <= to_integer(unsigned(address(word_offset_size + index_size - 1 DOWNTO word_offset_size)));
    controller_index <= to_integer(unsigned(controller_address(word_offset_size + index_size - 1 DOWNTO word_offset_size)));

    tag <= address(word_offset_size + index_size + tag_size - 1 DOWNTO word_offset_size + index_size);
    controller_tag <= controller_address(word_offset_size + index_size + tag_size - 1 DOWNTO word_offset_size + index_size);

    data_out <= cache(index).words(word_offset) & cache(index).words(word_offset + 1);
    controller_data_out_generate : FOR I IN 0 TO words_number_in_block - 1 GENERATE
        controller_data_out(I * word_size TO (I + 1) * word_size - 1) <= cache(controller_index).words(I);
    END GENERATE controller_data_out_generate;

    hit <= '1' WHEN (cache(index).valid = '1') AND (cache(index).tag = tag) ELSE '0';
    valid <= cache(index).valid;
    dirty <= cache(index).dirty;
    current_tag <= cache(index).tag;

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                cache <= (OTHERS => zero_entry);
            ELSIF force_wr = '1' THEN
                cache(controller_index).tag <= controller_tag;
                FOR I IN 0 TO words_number_in_block - 1 LOOP
                    cache(controller_index).words(I) <= controller_data_in(I * word_size TO (I + 1) * word_size - 1);
                END LOOP;
                cache(controller_index).dirty <= '0';
                cache(controller_index).valid <= '1';
            ELSIF (wr = '1') AND (hit = '1') THEN
                cache(index).words(word_offset) <= data_in(2 * word_size - 1 DOWNTO word_size);
                cache(index).words(word_offset + 1) <= data_in(word_size - 1 DOWNTO 0);
                cache(index).dirty <= '1';
            END IF;
        END IF;
    END PROCESS;
END data_cache_operation;