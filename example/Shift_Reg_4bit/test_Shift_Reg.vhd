-------------------------------------------------------------------------------
-- File : test_Shigt_reg
-- Testbanch source file : Shift_Reg.vhd
-- Author : Jampag
-- Description: This is an implementation of a 4 bit register
--              cehavioral architecture.
--
-- Block Diagram:
--
--    **** "test_Shigt_reg" *****************************
--    *                       ____________               *
--    * [Stimulus]► data_in -|            |- A ►[Signal]  *
--    *                      |  Shift_Reg |               *
--    *    [Stimulus]► clk  -|            |- B ►[Signal]  *    
--    *                      |            |               *
--    *                      |            |- C ►[Signal]  *    
--    *                      |            |               *
--    *   [Stimulus]► reset -|____________|- D ►[Signal]  *
--     *                                                  * 
--      ***************************************************
--
-------------------------------------------------------------------------------

-- Library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity test_Shigt_reg is
end test_Shigt_reg;

architecture test of test_Shigt_reg is

    -- Component Declaration
    component Shift_Reg
    port ( 
        A       : out std_logic;
        B       : out std_logic;
        C       : out std_logic;
        D       : out std_logic;
        data_in : in  std_logic;
        clk     : in  std_logic;
        reset   : in  std_logic);
    end component;

   -- Signal for Simulation
   --   Input
   signal data_in : std_logic := '0';
   signal reset   : std_logic := '0';
   signal clk     : std_logic := '0';
   --   Output
   signal A,B,C,D : std_logic;

begin

    -- Instance the Unit Under Test (UUT)
    dev_to_test: Shift_Reg
	    -- Rispetta la sequenza  di "architecture"
		port map (A, B, C, D, data_in, clk, reset);
		
		-- In alternative:
        -- port map (
        --     A => A,
        --     B => B,
        --     C => C,
        --     D => D,
        --     data_in => data_in,
        --     clk => clk,
        --     reset => reset
        -- );
		

    -- Generate clock source __|‾|_|‾|_|‾|_|‾|_
    clk_stimulus: process
	begin
	    wait for 10 ns;
		clk <= not clk;
	end process clk_stimulus;
	
	-- Generate data_in after 40ns for 150ns
	data_stimulus: process
	begin
	    wait for 40ns;
		data_in <= not data_in;
		wait for 150ns;
	end process data_stimulus;
	
	-- Generate a reset after 100ns
	reset_stimulus: process
	begin
        wait for 500ns;
        reset <= '1';
        wait for 100ns;
        reset <= '0';
    end process reset_stimulus;

end test;
