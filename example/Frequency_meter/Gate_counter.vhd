-------------------------------------------------------------------------------
-- File     : Gate_counter.vhd
-- Author   : Jampag
-- Date     : 2026 October 21
-- Revision : 1.0 
-- Description: Generates a strobe pulse every second. The strobe width is
--              equal to one "i_Clk" period. Every "G_CLOCK_FREQ" counts the 
--              pulse strobe is asserted.
--                
-- Block Diagram:
--
--                  ________________  __________
--                 |                ||          |
--       i_Clk ----|CK         [n:0]||=         |------> o_Gate
--                 |    COUNTER     ||  COMPARE |
--     i_Reset ----|RST             ||__________|
--                 |________________|
--                                   
-- Timing Example: G_CLOCK_FREQ = 4
--
--                __    __    __    __    __    __    __    __
--      i_Clk    ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  ^  |
--             __|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__
--                0     1     2     3     0     1     2     3      Count
--                                  _____                   _____
--    o_Gate  _____________________|     |_________________|     |__
--
--
-- Dependencies: x
-- Note: x
--

library IEEE;
use IEEE.STD_lOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;

entity Gate_counter is
    generic(
        G_CLOCK_FREQ : integer := 100_000_000);
    port(
        i_Reset : in std_logic;
        i_Clk   : in std_logic;
        o_Gate  : out std_logic
    );
end Gate_counter;

architecture Behavioral of Gate_counter is

    constant BIT_DEPTH  : integer := integer(ceil(log2(real(G_CLOCK_FREQ))));
    constant MAX_VAL    : unsigned(BIT_DEPTH-1 downto 0 ) := to_unsigned(G_CLOCK_FREQ - 1, BIT_DEPTH);
    
    signal r_count      : unsigned(BIT_DEPTH-1 downto 0 ) := (others => '0');
    signal o_Gate_reg   : std_logic := '0';

begin

    o_Gate <= o_Gate_reg;

    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            
            if (i_Reset = '0') then
                r_count <= (others => '0');
                o_Gate_reg <= '0';
            elsif ( r_count = MAX_VAL ) then
                r_count <= (others => '0');
                o_Gate_reg <= '1';
            else
                r_count <= r_count + 1;
                o_Gate_reg <= '0';
            end if;
            
        end if;
    end process;

end Behavioral;    