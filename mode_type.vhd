LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

PACKAGE mode_type IS
       TYPE Mode IS (Forwarding, Hazard_Detection, None);
END PACKAGE;
