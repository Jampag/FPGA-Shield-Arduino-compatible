-------------------------------------------------------------------------------
-- File : test_DFF
-- Autor : Jampag
-- Description: D Flip Flop with Clock Enable and Sync Reset
-- Block Diagram:
--
--    **** "test_DFF" **********************************
--    *                       ____________               *
--    * [Stimulus]► Data    -|            |- Q ►[Signal]  *
--    *                      |  DFF       |               *
--    * [Stimulus]► Clk     -|            |               *    
--    *                      |            |               *
--    * [Stimulus]► CE      -|            |               *    
--    *                      |            |               *
--    * [Stimulus]► R       -|____________|               *
--     *                                                  * 
--      ***************************************************

 
-------------------------------------------------------------------------------

-- Library 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity test_DFF is
end test_DFF;

architecture test of test_DFF is

    -- Component Declaration
    component DFlipFlop
    port (
        Data	: in std_ulogic;
        Clk		: in std_ulogic;
    	CE      : in std_ulogic;
        Reset	: in std_ulogic;
        Q		: out std_ulogic);
    end component;
    

   -- Signal for Simulation
   -- Input
   signal Data  : std_logic := '0';
   signal Clk   : std_logic := '0';
   signal CE    : std_logic := '0';
   signal Reset : std_logic := '0';
   -- Output
   signal Q : std_logic;
   
   -- Clock period (simulazione di 10 ns)
   constant CLK_PERIOD : time := 10 ns;

begin

   -- Instance the Unit Under Test (UUT)
    dev_to_test: DFlipFlop
	    -- Rispetta la sequenza  di "architecture"
		port map (Data, Clk, CE, Reset, Q);

   -- Generate clock source __|‾|_|‾|_|‾|_|‾|_
    clk_stimulus: process
	begin
	    Clk <= not Clk;
        wait for CLK_PERIOD / 2;
		Clk <= not Clk;
		wait for CLK_PERIOD / 2;
	end process clk_stimulus;

   -- Stimolus Data, Reset & CE
    stimulus: process
    begin
        wait for CLK_PERIOD;
		
		--CE
        CE<= '1'; -- Enable 
        
        --Reset
		Reset <= '1'; -- Reset Enable
		wait for CLK_PERIOD + (CLK_PERIOD / 2);
        Reset <= '0'; -- Reset Disable
        
		--Data
        Data <= '1';
		wait for CLK_PERIOD * 2;
		Data <= '0';
		wait for CLK_PERIOD + 1ns ;
		Data <= '1';
		wait for CLK_PERIOD + 1ns ;
		Data <= '0';
		wait for CLK_PERIOD + 1ns ;
		Data <= '1';
		wait for CLK_PERIOD + 1ns ;
		Data <= '0';
		wait for CLK_PERIOD + 1ns ;
		Data <= '1';
		wait for CLK_PERIOD;
		Data <= '0';
		wait for CLK_PERIOD;
		Data <= '1';
		wait for CLK_PERIOD;
		Data <= '0';
		wait for CLK_PERIOD;
		Data <= '1';
        
        CE<= '0'; -- Disable
		wait for CLK_PERIOD * 4;
        CE<= '1'; -- Enable
        wait for CLK_PERIOD / 2;
        CE<= '0'; -- Disable
        wait for CLK_PERIOD * 2;
        
        wait for CLK_PERIOD;
		Data <= '0';
		wait for CLK_PERIOD;
		Data <= '1';
        wait for CLK_PERIOD;
              
		--Reset
		Reset <= '1'; -- Reset Enable
		wait for CLK_PERIOD;
        Reset <= '0'; -- Reset Disable

    end process stimulus;


end test;
