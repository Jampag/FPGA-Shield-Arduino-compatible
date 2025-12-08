-------------------------------------------------------------------------------
-- File : test_T_DFF
-- Autor : Jampag
-- Description: T DFlip Flop based on DFF
-- Block Diagram:
--
--    **** "test_T_DFF" **********************************
--    *                       ____________               *
--    * [Stimulus]► T       -|T           |- Q ►[Signal]  *
--    *                      |    TFF     |               *
--    * [Stimulus]► Clk     -|            |               *    
--    *                      |            |               *
--    *                      |____________|               *
--     *                                                  * 
--      ***************************************************
-------------------------------------------------------------------------------

-- Library 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity test_T_DFF is
end test_T_DFF;

architecture test of test_T_DFF is

    -- Component Declaration
    component T_DFF
    port (
        T       : in std_ulogic;
        Clk     : in std_ulogic;
        Q       : out std_ulogic);
    end component;
    

   -- Signal for Simulation
   -- Input
   signal T : std_logic := '0';
   signal Clk : std_logic := '0';
   -- Output
   signal Q : std_logic;
   
   -- Clock period (simulazione di 10 ns)
   constant CLK_PERIOD : time := 10 ns;

begin

   -- Instance the Unit Under Test (UUT)
    dev_to_test: T_DFF    
        port map (T, Clk, Q);

   -- Generate clock source __|‾|_|‾|_|‾|_|‾|_
    clk_stimulus: process
    begin
        Clk <= not Clk;
        wait for CLK_PERIOD / 2;
        Clk <= not Clk;
        wait for CLK_PERIOD / 2;
    end process clk_stimulus;

   -- Stimolus T
    stimulus: process
    begin
        wait for CLK_PERIOD;
        
        --T
        T <= '1';
        wait for CLK_PERIOD * 4 ;
        T <= '0';
        wait for CLK_PERIOD + 1ns ;
        T <= '1';
        wait for CLK_PERIOD * 2 + 1ns ;
    end process stimulus;


end test;
