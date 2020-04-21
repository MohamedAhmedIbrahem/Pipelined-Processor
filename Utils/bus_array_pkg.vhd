LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

PACKAGE bus_array_pkg is
        TYPE bus_array IS ARRAY (natural range <>) OF std_logic_vector;
END PACKAGE;
