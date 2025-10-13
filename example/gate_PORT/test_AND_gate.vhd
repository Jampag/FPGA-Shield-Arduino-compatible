-------------------------------------------------------------------------------
-- File : test_AND_gate
-- Autor : Jampag
-- Description: AND Gate
--        ______
-- A ----|      \
--       | AND   )---- Y
-- B ----|______/
-- 
-- Block Diagram:
--
--    **** "test_Shigt_reg" ******************************
--    *                       ______                     *
--    *    [Stimulus]► A ----|      \                    *
--    *                      | AND   )---- Y ►[Signal]   *
--    *    [Stimulus]► B ----|______/                    *
--    ****************************************************
--              
-------------------------------------------------------------------------------

-- Library 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity test_AND_gate is
end test_AND_gate;

architecture test of test_AND_gate is

    -- Component Declaration
    component AND_gate
    port (
	    A       : in std_logic;
	    B       : in std_logic;
	    Y       : out std_logic);
    end component;
    

   -- Signal for Simulation
   -- Input
   signal A : std_logic := '0';
   signal B : std_logic := '0';
   -- Output
   signal Y : std_logic;

begin

    -- Instance the Unit Under Test (UUT)
    dev_to_test: AND_gate
	    -- Respect the "architecture" sequence
		port map (A, B, Y);
		
    -- Stimolus A and B cases
    AB_stimulus: process
    begin
        wait for 10 ns;
        
        --Case 1 [ A=0 & B=0 -> Y=0]
        A <= '0'; B <='0';
        wait for 15 ns;
        
        --Case 2 [ A=0 & B=1 -> Y=0]
        A <= '0'; B <='1';
        wait for 15 ns;
        
        --Case 3 [ A=1 & B=0 -> Y=0]
        A <= '1'; B <='0';
        wait for 15 ns;
        
        --Case 4 [ A=1 & B=1 -> Y=1]
        A <= '1'; B <='1';
        wait for 15 ns;
        
    end process AB_stimulus;


end test;
