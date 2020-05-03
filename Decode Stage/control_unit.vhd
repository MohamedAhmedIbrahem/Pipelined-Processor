LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY control_unit IS
    PORT (
        opcode : IN std_logic_vector(0 TO 4);
        alu_input : OUT std_logic_vector(3 DOWNTO 0);
        wb1 : OUT std_logic;
        wb2 : OUT std_logic;
        wr : OUT std_logic;
        rd : OUT std_logic;
        mem : OUT std_logic;
        pc_wb : OUT std_logic;
        flags_wb : OUT std_logic;
        flags_update : OUT std_logic;
        is_src1 : OUT std_logic;
        is_src2 : OUT std_logic;
        sp : OUT std_logic;
        swap : OUT std_logic;
        jz : OUT std_logic;
        mux_1_selectors : OUT std_logic_vector(1 DOWNTO 0);
        mux_4_selectors : OUT std_logic_vector(1 DOWNTO 0);
        mux_5_selectors : OUT std_logic;
        mux_7_selectors : OUT std_logic;
        mux_8_selectors : OUT std_logic
    );
END control_unit;

ARCHITECTURE control_unit_operation OF control_unit IS
    SIGNAL control_signals : std_logic_vector(22 DOWNTO 0);
BEGIN
    WITH opcode SELECT control_signals <=
        "00001000000110101011000" WHEN "10001",
        "01011000001110001011001" WHEN "10101",
        "01101000001110001011001" WHEN "10110",
        "01111000001110001011001" WHEN "10111",
        "10001000001110001011001" WHEN "11000",
        "00101000001100001000000" WHEN "10010",
        "00111000001100001000000" WHEN "10011",
        "01001000001100001000000" WHEN "10100",
        "10011000001100001001010" WHEN "00001",
        "10101000001100001001010" WHEN "00010",
        "00001010000000000000000" WHEN "11010",
        "00001011000000000010000" WHEN "01001",
        "10111000000000000001000" WHEN "00101",
        "00001011000001000000000" WHEN "11011",
        "00000101000101001000100" WHEN "11101",
        "00000101000100001010000" WHEN "01010",
        "00000101000101001000100" WHEN "11110",
        "00000100000100001000000" WHEN "11111",
        "01011000001100001001001" WHEN "00110",
        "00000011100001000000000" WHEN "01101",
        "00000011010001000000000" WHEN "01110",
        "00000101000001000000100" WHEN "00011",
        "00000101000001000100100" WHEN "00111",
        "00000011100000000010000" WHEN "01111",
        "00000011100000000010000" WHEN "10000",
        "00000000000000000000000" WHEN "00000",
        "00000000000100011000000" WHEN "11001",
        "00000000000100001000000" WHEN "11100",
        "00000000000000000000000" WHEN OTHERS;

    alu_input <= control_signals(22 DOWNTO 19);
    wb1 <= control_signals(18);
    wr <= control_signals(17);
    rd <= control_signals(16);
    mem <= control_signals(15);
    pc_wb <= control_signals(14);
    flags_wb <= control_signals(13);
    flags_update <= control_signals(12);
    is_src1 <= control_signals(11);
    is_src2 <= control_signals(10);
    sp <= control_signals(9);
    swap <= control_signals(8);
    wb2 <= control_signals(8);
    jz <= control_signals(7);
    mux_1_selectors <= control_signals(6 DOWNTO 5);
    mux_4_selectors <= control_signals(4 DOWNTO 3);
    mux_5_selectors <= control_signals(2);
    mux_7_selectors <= control_signals(1);
    mux_8_selectors <= control_signals(0);

END control_unit_operation;