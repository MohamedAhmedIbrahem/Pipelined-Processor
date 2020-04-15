LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY ALU IS 
    PORT(
        A , B : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        OP    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        C     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        FLAGS : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)    -- C & N & Z
    );
END ENTITY;

ARCHITECTURE arch OF ALU IS 
BEGIN 
    PROCESS(A,B,OP)
    VARIABLE RES : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    VARIABLE CARRY : STD_LOGIC;
    BEGIN 
		CARRY := '0';
        IF OP = "0010" THEN		-- NOT
            RES := NOT A;
        ELSIF OP = "0011" THEN	-- INC
            RES := A + 1;
        ELSIF OP = "0100" THEN	-- DEC
            RES := A - 1;
        ELSIF OP = "0101" THEN	-- ADD
            RES := A + B;
        ELSIF OP = "0110" THEN	-- SUB
            RES := A - B;
        ELSIF OP = "0111" THEN	-- AND
            RES := A AND B;
        ELSIF OP = "1000" THEN	-- OR
            RES := A OR B;
        ELSIF OP = "1001" THEN  -- SHL
            RES := STD_LOGIC_VECTOR(UNSIGNED(A) SLL TO_INTEGER(UNSIGNED(B)));
            CARRY := A(32 - TO_INTEGER(UNSIGNED(B)));
        ELSIF OP = "1010" THEN  -- SHR
            RES := STD_LOGIC_VECTOR(UNSIGNED(A) SRL TO_INTEGER(UNSIGNED(B)));
            CARRY := A(TO_INTEGER(UNSIGNED(B)) - 1);
        END IF;
        C <= RES;
	IF RES = x"00000000" THEN
	    FLAGS(0) <= '1';
	ELSE 
	    FLAGS(0) <= '0';
	END IF;
        FLAGS(1) <= RES(31);
        FLAGS(2) <= CARRY;
    END PROCESS;
END ARCHITECTURE;