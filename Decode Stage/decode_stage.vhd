LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY decode_stage IS
    PORT (
        CLK, RST : IN std_logic;
        IR_high : IN std_logic_vector(0 TO 15);
        IR_low : IN std_logic_vector(0 TO 15);
        decode_buffer_enable : IN std_logic;
        pc_transparent : IN std_logic_vector(31 DOWNTO 0);
        flags : IN std_logic_vector(3 DOWNTO 0);
        first_operand : OUT std_logic_vector(31 DOWNTO 0);
        second_operand : OUT std_logic_vector(31 DOWNTO 0);
        alu_input : OUT std_logic_vector(3 DOWNTO 0);
        flags_update : OUT std_logic;
        wb1 : OUT std_logic;
        wb2 : OUT std_logic;
        wr : OUT std_logic;
        rd : OUT std_logic;
        memory : OUT std_logic;
        pc_wb : OUT std_logic;
        flags_wb : OUT std_logic;
        src1 : OUT std_logic_vector(0 TO 2);
        src2 : OUT std_logic_vector(0 TO 2);
        is_src1 : OUT std_logic;
        is_src2 : OUT std_logic;
        dst1 : OUT std_logic_vector(0 TO 2);
        dst2 : OUT std_logic_vector(0 TO 2);
        jz : OUT std_logic;
        WR1_enable : IN std_logic;
        WR2_enable : IN std_logic;
        WR1_address : IN std_logic_vector(0 TO 2);
        WR2_address : IN std_logic_vector(0 TO 2);
        WR1_data : IN std_logic_vector(31 DOWNTO 0);
        WR2_data : IN std_logic_vector(31 DOWNTO 0);
        RD3_address : IN std_logic_vector(0 TO 2);
        RD3_data : OUT std_logic_vector(31 DOWNTO 0)
    );
END decode_stage;

ARCHITECTURE decode_stage_operation OF decode_stage IS
    SIGNAL sp, swap, mux_5_selectors, mux_7_selectors, mux_8_selectors, sp_enable : std_logic;
    SIGNAL mux_1_selectors, mux_4_selectors : std_logic_vector(1 DOWNTO 0);
    SIGNAL RD1, RD2, sp_data_in, sp_data_out, sp_to_operand, immediate_to_operand : std_logic_vector(31 DOWNTO 0);
BEGIN

    src1 <= IR_high(7 TO 9) WHEN mux_8_selectors = '0'ELSE
        IR_high(10 TO 12);
    src2 <= IR_high(13 TO 15);
    dst1 <= IR_high(7 TO 9) WHEN swap = '0' ELSE
        IR_high(10 TO 12);
    dst2 <= IR_high(7 TO 9);

    WITH mux_1_selectors SELECT first_operand <=
        pc_transparent WHEN "00",
        x"0000000" & flags WHEN "01",
        RD1 WHEN OTHERS;

    control : ENTITY work.control_unit PORT MAP (IR_high(2 TO 6), alu_input, wb1, wb2, wr, rd, memory, pc_wb, flags_wb,
        flags_update, is_src1, is_src2, sp, swap, jz,
        mux_1_selectors, mux_4_selectors, mux_5_selectors, mux_7_selectors, mux_8_selectors);

    registers : ENTITY work.Register_File PORT MAP (CLK, RST, src1, src2, RD3_address, RD1, RD2, RD3_data,
        WR1_address, WR2_address, WR1_data, WR2_data, WR1_enable, WR2_enable);

    sp_enable <= decode_buffer_enable AND sp;
    WITH mux_5_selectors SELECT sp_data_in <=
        sp_data_out + x"2" WHEN '0',
        sp_data_out - x"2" WHEN OTHERS;
    sp_register : ENTITY work.SP_REG PORT MAP (CLK, RST, sp_enable, sp_data_in, sp_data_out);

    WITH mux_5_selectors SELECT sp_to_operand <=
        sp_data_in WHEN '0',
        sp_data_out WHEN OTHERS;

    WITH mux_7_selectors SELECT immediate_to_operand <=
        (31 DOWNTO 17 => IR_low(1 TO 15), OTHERS => IR_high(15)) WHEN '0',
        (31 DOWNTO 27 => IR_high(10 TO 14), OTHERS => '0') WHEN OTHERS;

    WITH mux_4_selectors SELECT second_operand <=
        sp_to_operand WHEN "00",
        immediate_to_operand WHEN "01",
        x"000" & IR_high(11 TO 15) & IR_low(1 TO 15) WHEN "10",
        RD2 WHEN OTHERS;
END decode_stage_operation;