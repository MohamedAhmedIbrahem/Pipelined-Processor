Library ieee;
use ieee.std_logic_1164.all;

entity branch_prediction_fsm is
	port (
		clk, rst, is_taken, enable: in std_logic;
		predicted_taken: out std_logic
	);
end entity;


architecture branch_prediction_fsm_arch of branch_prediction_fsm is
	type states is (STRONGLY_NOT_TAKEN, WEAKLY_NOT_TAKEN, WEAKLY_TAKEN, STRONGLY_TAKEN);
	constant initial_state: states := WEAKLY_NOT_TAKEN;
	constant TAKEN: std_logic := '1';
	constant NOT_TAKEN: std_logic := '0';
	signal current_state: states := initial_state;
begin
	process (clk, rst) 
	begin
		-- State update 
		if rst = '1' then
			current_state <= initial_state;
	    elsif rising_edge(clk) and enable = '1' then 
			case current_state is
				when STRONGLY_NOT_TAKEN => 
					if is_taken = TAKEN then current_state <= WEAKLY_NOT_TAKEN; 
					else current_state <= STRONGLY_NOT_TAKEN;
					end if;
				when WEAKLY_NOT_TAKEN =>
					if is_taken = TAKEN then current_state <= WEAKLY_TAKEN; 
					else current_state <= STRONGLY_NOT_TAKEN; 
					end if;
				when WEAKLY_TAKEN =>
					if is_taken = TAKEN then current_state <= STRONGLY_TAKEN; 
					else current_state <= WEAKLY_NOT_TAKEN; 
					end if;
				when others =>
					if is_taken = TAKEN then current_state <= STRONGLY_TAKEN; 
					else current_state <= WEAKLY_TAKEN; 
					end if;
			end case;
	    end if;
	end process;
	
	process(current_state)
	begin
	-- Calculate predicted_taken
        predicted_taken <= TAKEN WHEN current_state = WEAKLY_TAKEN or current_state = STRONGLY_TAKEN 
                            ELSE NOT_TAKEN;
	end process;
end;