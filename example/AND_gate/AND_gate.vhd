-------------------------------------------------------------------------------
-- File : Port_AND
-- Autor : F
-- Description: AND PORT
--        ______
-- A ----|      \
--       | AND   )---- Y
-- B ----|______/
-- 
--              
-------------------------------------------------------------------------------

-- Library 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entity Declaration
entity Port_AND is
    port (
        A		: in std_logic;
        B		: in std_logic;
        Y		: out std_logic);
end Port_AND;

-- Architecture
architecture behavior of Port_AND is

-- Begin Architecture
begin

    -- Signal Assignments
    Y <= (A AND B);
    
	
end behavior;
