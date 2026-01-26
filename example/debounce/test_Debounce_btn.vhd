-------------------------------------------------------------------------------
-- File : test_Debounce_btn
-- Testbanch source file : Debounce_btn.vhd
-- Autor : Jampag
-- Data : 2026 Jan 25
-- Description: validate the debounce module, to easy simulation reduce the 
--              DEBOUNCE_cnt at 4
--
-- Block Diagram: xxx
--
--
-------------------------------------------------------------------------------

-- Library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity test_Debounce_btn is
end test_Debounce_btn;

architecture test of test_Debounce_btn is

    -- Component Declaration
    component Debounce_btn
    generic(
        DEBOUNCE_cnt    : integer;
        INIT_state      : std_logic
    );
    Port (
        i_clk    : in std_logic;
        i_bounce : in std_logic;
        o_debounce : out std_logic
        );
    end component;

   -- Signal for Simulation
   --   Input
   signal i_clk : std_logic := '0';
   signal i_bounce   : std_logic := '0';
   --   Output
   signal o_debounce : std_logic;

begin
    -- Instance the Unit Under Test (UUT)
    dev_to_test: Debounce_btn
        generic map(
            DEBOUNCE_cnt    => 4,
            INIT_state      => '1'
        )
        -- Respect the "architecture" sequence
        port map (i_clk, i_bounce,o_debounce);
        

    -- Generate clock source __|‾|_|‾|_|‾|_|‾|_
    clk_stimulus: process
    begin
        wait for 10 ns;
        i_clk <= not i_clk;
    end process clk_stimulus;
    
    -- Generate 
    data_stimulus: process
    begin
        i_bounce <= '1';
        wait for 70ns;
        i_bounce <= '1';
        wait for 250ns;
        i_bounce <= '0';
        wait for 1ns;
        wait until rising_edge(i_clk);
        i_bounce <= '1';
        wait until rising_edge(i_clk);
        i_bounce <= '0';
        wait until rising_edge(i_clk);
        i_bounce <= '1';
        wait until rising_edge(i_clk);
        i_bounce <= '0';        
        wait for 250ns;
    end process data_stimulus;

end test;
