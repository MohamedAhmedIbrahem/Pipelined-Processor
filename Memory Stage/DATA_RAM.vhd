LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DATA_RAM IS
    GENERIC(CellSize: INTEGER := 16; AddressWidth: INTEGER := 11);
    PORT(
        CLK             : IN  STD_LOGIC;
        WR              : IN  STD_LOGIC;
        RD              : IN  STD_LOGIC;
        Address         : IN  STD_LOGIC_VECTOR(AddressWidth-1 DOWNTO 0);
        Din             : IN  STD_LOGIC_VECTOR(8*CellSize-1 DOWNTO 0);
		Done			: OUT STD_LOGIC;
        Dout            : OUT STD_LOGIC_VECTOR(8*CellSize-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_DATA_RAM OF DATA_RAM IS
    CONSTANT MEMORY_SIZE: integer := 2**11;
    TYPE memory IS ARRAY(0 TO MEMORY_SIZE-1) OF STD_LOGIC_VECTOR(CellSize-1 DOWNTO 0);
    SIGNAL Mem : memory := (OTHERS => (OTHERS => '0'));
	SIGNAL WCounter,RCounter : integer := -1;
BEGIN  
    PROCESS(CLK)
	VARIABLE RDCounter,WRCounter : integer;
    BEGIN	
		IF RISING_EDGE(CLK) THEN
			RDCounter := RCounter;
			WRCounter := WCounter;
			IF WR='1' THEN
				WRCounter := 0;
			ELSIF RD='1' THEN
				RDCounter := 0;
			ELSE
				IF WRCounter /= -1 THEN
					Mem(TO_INTEGER(UNSIGNED(Address) + 2*WRCounter)) 	 <= Din((8-2*WRCounter)*CellSize-1 DOWNTO (8-2*WRCounter-1)*CellSize);
					Mem(TO_INTEGER(UNSIGNED(Address) + 2*WRCounter + 1)) <= Din((8-2*WRCounter-1)*CellSize-1 DOWNTO (8-2*WRCounter-2)*CellSize);
					WRCounter := WRCounter + 1;
				ELSIF RDCounter /= -1 THEN
					Dout((8-2*RDCounter)*CellSize-1 DOWNTO (8-2*RDCounter-1)*CellSize)  <= Mem(TO_INTEGER(UNSIGNED(Address) + 2*RDCounter));
					Dout((8-2*RDCounter-1)*CellSize-1 DOWNTO (8-2*RDCounter-2)*CellSize)<= Mem(TO_INTEGER(UNSIGNED(Address) + 2*RDCounter + 1));
					RDCounter := RDCounter + 1;
				END IF;
			END IF;
			IF WRCounter = 4 OR RDCounter = 4 THEN 
				Done <= '1';
				WRCounter := -1;
				RDCounter := -1;
			ELSE
				Done <= '0';
			END IF;
			WCounter <= WRCounter;
			RCounter <= RDCounter;
		END IF;
    END PROCESS;
END ARCHITECTURE arch_DATA_RAM;
--11111111111111110000000000000000111111111111111100000000000000001111111111111111000000000000000011111111111111110000000000000000