-------------------------------------------------------------------------------
-- File : test_DIV_by_2_DFF.vhd
-- Testbanch source file : DIV_by_2_DFF.vhd
-- Author : Jampag
-- Description: This is an implementation of a Div by 2 Clk
--              Behavioral architecture.
--
-- Block Diagram:
--
--    **** "test_DIV_by_2_DFF" **************************
--    *                       ____________               *
--    *                      |            |               *
--    *                      |   DIV/2    |               *
--    *    [Stimulus]► Clk  -|            |- Q ►[Signal]  *    
--    *                      |____________|               *
--     *                                                  *
--      ***************************************************
--
-------------------------------------------------------------------------------

-- Library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity test_DIV_by_2_DFF is
end test_DIV_by_2_DFF;

architecture test of test_DIV_by_2_DFF is

    -- Component Declaration
    component DIV2
    port ( 
        Clk     : in std_logic;
        Q       : out std_logic);
    end component;

   -- Signal for Simulation
   -- Input
   signal Clk     : std_logic := '0';
   -- Output
   signal Q : std_logic;

begin

    -- Instance the Unit Under Test (UUT)
    dev_to_test: DIV2
	    -- Respect the "architecture" sequence
		port map (
            Clk => Clk,
            Q => Q
        );
		

    -- Generate clock source __|‾|_|‾|_|‾|_|‾|_
    clk_stimulus: process
	begin
	    wait for 20 ns;
		Clk <= not Clk;
	end process clk_stimulus;

end test;
