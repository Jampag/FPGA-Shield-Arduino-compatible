-------------------------------------------------------------------------------
-- File     : pwm.vhd
-- Author   : Jampag
-- Date     : 2026 april 16
-- Revision : 1.0 
-- Description:
--   PWM (Pulse Width Modulation) signal generator.
--   The module generates a PWM waveform with programmable duty cycle
--   resolution defined by BIT_DEPTH.
-- Timing Example:
--               __    __    __    __     __     __     __     __     __    
--  i_clk       ^  |  ^  |  ^  |  ^  |   ^  |   ^  |   ^  |   ^  |   ^  |   
--            __|  |__|  |__|  |__|  |___|  |___|  |___|  |___|  |___|  |___
--                _______________________________________________________
--  i_enable     |  
--             __|  
--                     _____               _____               ______
--  o_PWM             |     |             |     |             |      |     
--            ________|     |_____________|     |_____________|      |____
--
-- Dependencies: x
-- Note: 
--  Constraint for valid operation INPUT_CLK / FREQ_PWM >= 2^BIT_DEPTH

-- Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- Entity
entity PWM is
    generic (
        BIT_DEPTH : integer := 8;
        INPUT_CLK : integer := 100_000_000;
        FREQ_PWM  : integer := 1_000 -- 1KHz
    );
    port (
        o_PWM        : out std_logic;
        i_duty_cycle : in  std_logic_vector(BIT_DEPTH - 1 downto 0);
        i_clk        : in  std_logic;
        i_enable     : in  std_logic
    );
end PWM;

-- Architecture
architecture behavior of PWM is

    -- Constants
    constant MAX_FREQ_COUNT : integer := INPUT_CLK / FREQ_PWM;
    constant PWM_STEP       : integer := MAX_FREQ_COUNT / (2**BIT_DEPTH);

    -- Counter bit depth
    constant MAX_FREQ_BIT   : integer := integer(ceil(log2(real(MAX_FREQ_COUNT))));
    constant PWM_STEP_BIT   : integer := integer(ceil(log2(real(PWM_STEP))));

    -- Convert integer to unsigned to compare
    constant MAX_FREQ_COUNT_U : unsigned(MAX_FREQ_BIT - 1 downto 0) := 
        to_unsigned(MAX_FREQ_COUNT, MAX_FREQ_BIT);      
    
    constant PWM_STEP_U : unsigned(PWM_STEP_BIT - 1 downto 0) :=
        to_unsigned(PWM_STEP, PWM_STEP_BIT);

    -- Signals
    signal reg_PWM        : std_logic := '0';
    signal freq_count     : unsigned(MAX_FREQ_BIT - 1 downto 0) := (others => '0');
    signal pwm_count      : unsigned(BIT_DEPTH - 1 downto 0) := (others => '0');
    signal pwm_count_max  : unsigned(BIT_DEPTH - 1 downto 0) := (others => '0');
    signal pwm_step_count : unsigned(PWM_STEP_BIT - 1 downto 0) := (others => '0');

begin

    -- Convert duty cycle input
    pwm_count_max <= unsigned(i_duty_cycle);

    -- Output assignment
    o_PWM <= reg_PWM;

    -- PWM signal counter
    freq_counter : process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_enable = '1' then
                if freq_count < MAX_FREQ_COUNT_U - 1 then
                    freq_count <= freq_count + 1;

                    if pwm_count < pwm_count_max then
                        reg_PWM <= '1';
                        if pwm_step_count < PWM_STEP_U then
                            pwm_step_count <= pwm_step_count + 1;
                        else
                            pwm_step_count <= (others => '0');
                            pwm_count <= pwm_count + 1;
                        end if;

                    else
                        reg_PWM <= '0';
                    end if;

                else
                    freq_count <= (others => '0');
                    pwm_count <= (others => '0');
                    pwm_step_count <= (others => '0');
                end if;

            else
                reg_PWM <= '0';
                freq_count <= (others => '0');
                pwm_count <= (others => '0');
                pwm_step_count <= (others => '0');
            end if;

        end if;
    end process;

end behavior;
