-------------------------------------------------------------------------------
-- File : test_pwm
-- Testbanch source file : pwm.vhd
-- Author : Jampag
-- Date : 2026 april 16
-- Description: validate the debounce module, to easy simulation increse the 
--              FREQ_PWM 390KHz
--
-- Block Diagram: xxx
--
--
-------------------------------------------------------------------------------

-- Library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity test_pwm is
end test_pwm;

architecture test of test_pwm is

    -- Component Declaration
    component pwm
    generic (
        BIT_DEPTH : integer;
        INPUT_CLK : integer;
        FREQ_PWM  : integer
    );    
    port (
        o_PWM        : out std_logic;
        i_duty_cycle : in  std_logic_vector(BIT_DEPTH - 1 downto 0);
        i_clk        : in  std_logic;
        i_enable     : in  std_logic
    );    
    end component;

   -- Signal for Simulation
   --   Input
   signal i_clk         : std_logic := '0';
   signal i_en          : std_logic := '0';
   signal i_dt          : std_logic_vector(8 - 1 downto 0) := (others => '0');
   --   Output
   signal o_PWM : std_logic;

begin
    -- Instance the Unit Under Test (UUT)
    dev_to_test: pwm
        generic map(
            BIT_DEPTH   => 8,
            INPUT_CLK   => 100_000_000,
            FREQ_PWM    => 390_000
        )
        -- Respect the "architecture" sequence
        port map (o_PWM, i_dt,i_clk,i_en);
        

    -- Generate clock source __|‾|_|‾|_|‾|_|‾|_
    clk_stimulus: process
    begin
        wait for 10 ns;
        i_clk <= not i_clk;
    end process clk_stimulus;
    
    -- Generate 
    data_stimulus: process
    begin
        i_dt <=  x"7f"; -- PWM 50%
        
        i_en <= '0';
        wait for 150ns;
        i_en <= '1';       
        wait for 12000ns;
        i_en <= '0';
        
        i_dt <=  x"3f"; -- PWM 25%
        wait for 150ns;
        i_en <= '1';       
        wait for 12000ns;        
        

    end process data_stimulus;

end test;
