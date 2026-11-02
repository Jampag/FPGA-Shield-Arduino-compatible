-------------------------------------------------------------------------------
-- File     : Freq_counter.vhd
-- Author   : Jampag
-- Date     : 2026 October 21
-- Revision : 1.0 
-- Description: Free-running counter. When 'i_Reset' is asserted, the current
--              count plus one is stored and made available on 'o_count'. The
--              counter is then cleared and the 'o_upd_toggle' signal changes
--              state (toggles) to indicate that new data is available.
--              
-- Block Diagram:
--
--                  ________________         ____________
--                 |                |  __   |            |
--   i_Clk_ext ----|CK         [n:0]|=|+1|==|D          Q|-----> o_count
--                 |  FREE-RUNNING  | |__|  | COUNT LATCH|
--     i_Reset -+--|RST             |     .-|EN          |
--              |  |________________|     | |____________|
--              |                         |
--              '-------------------------'
--                  ________________
--                 |                |
--   i_Clk_ext ----|CK              |
--                 |  UPDATE TOGGLE |---------------> o_upd_toggle
--     i_Reset ----|TGL             |
--                 |________________|
--                                   
-- Timing Example:
--
--                  __    __    __    __    __    __    __    __    __
--  i_Clk_ext      ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  ^  |
--               __|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__
--               
--                                     _____             _____
--  i_Reset      _____________________|     |___________|     |__________
--               
--  r_counter      |  0  |  1  |  2  |  3  |  4  |  0  |  1  |  2  |  0
--               
--  o_count        |  0  |  0  |  0  |  0  |  0  |  5  |  5  |  5  |  3
--                                                _________________ 
--  o_upd_toggle ________________________________|                 |______
--                                               ^                 ^
--                                               |                 |
--                                        First update       Second update
--  
-- Dependencies: x
-- Note: 'i_Reset' must be asserted for only one i_Clk_ext cycle. If 'i_Reset'
--       remains asserted for multiple clock cycles, 'o_upd_toggle' changes
--       state on every clock cycle while 'i_Reset' is high.
--
library IEEE;
use IEEE.STD_lOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Freq_counter is
    generic(
        G_BIT_DEPTH : integer := 32 );
    port(
        i_Reset      : in std_logic;
        i_Clk_ext    : in std_logic;
        o_count      : out std_logic_vector(G_BIT_DEPTH - 1 downto 0 );
        o_upd_toggle : out std_logic
    );
end Freq_counter;

architecture Behavioral of Freq_counter is

    signal r_counter : unsigned(G_BIT_DEPTH-1 downto 0 ) := (others => '0');
    signal r_counter_latch : unsigned(G_BIT_DEPTH-1 downto 0 ) := (others => '0');
    signal r_upd_toggle : std_logic := '0';

begin

    o_count <= std_logic_vector(r_counter_latch);
    o_upd_toggle <= r_upd_toggle;

    process(i_Clk_ext)
    begin
        if rising_edge(i_Clk_ext)then
        
            if(i_Reset = '1') then
                r_counter <= (others => '0');
                r_counter_latch <= r_counter + 1;
                r_upd_toggle <= not r_upd_toggle;
            else
                r_counter <= r_counter + 1;
            end if;
        
        end if;
    end process;

end Behavioral;