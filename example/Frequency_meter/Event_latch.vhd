-------------------------------------------------------------------------------
-- File     : Event_latch.vhd
-- Author   : Jampag
-- Date     : 2026 October 21
-- Revision : 1.0 
-- Description: Captures i_Data on every clock cycle, when i_Data become '1' 
--              o_DataLatch is set at '1' and remains asseted, when i_Reset
--              signal is asserted o_DataLatch return to '0'.
--
-- Block Diagram: 
--
--    [1]
--     |     _______ 
--     '----|D     Q|--> o_DataLatch
--  i_Data -|CE     |
--   i_Clk -|CK     |
-- i_Reset -|RST    | 
--          |_______|
-- 
-- Timing Example:
--
--   i_Clk         |__|__|__|__|__|__|__|__|__|__|__|
--
--   i_Reset        0  0  0  0  0  0  0  1  1  0  0
--   i_Data         0  0  1  0  0  1  0  0  0  0  0
--   o_DataLatch    0  0  0  1  1  1  1  0  0  0  0
--
-- Dependencies: x
-- Note: x

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Event_latch is
    port(
        i_Clk   : in std_logic;
        i_Data  : in std_logic;
        i_Reset : in std_logic;
        o_DataLatch : out std_logic
    );
end Event_latch;

architecture behavior of Event_latch is

    signal r_Data : std_logic := '0';

begin

    o_DataLatch <= r_Data;

    process(i_Clk)
        begin
            if rising_edge(i_Clk) then
            
                if(i_Reset = '1') then
                    r_Data <= '0';
                    
                elsif (i_Data = '1') then
                    r_Data <= '1';
                end if;
            
            end if;    
    end process;

end behavior;