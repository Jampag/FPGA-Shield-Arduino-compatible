-------------------------------------------------------------------------------
-- File     : Sync_2FF.vhd
-- Author   : Jampag
-- Date     : 2026 October 21
-- Revision : 1.0 
-- Description: Two-stage flip-flop synchronizer used to safely transfer an
--              asynchronous signal into the local clock domain. The second
--              flip-flop reduces metastability propagation. 
--              The synchronized output is available after two clock cycles.
--
-- Block Diagram: 
--
--     i_Clk ------+--------------------+
--   i_Reset ----+-|------------------+-|
--               | |                  | |
--             __|_|_               __|_|_
--   i_Async -|D    Q|-------------|D    Q|--> o_Sync
--            | DFF0 |             | DFF1 |
--            |______|             |______|
-- 
-- Timing Example:
--                __    __    __    __    __
--     i_Clk     ^  |  ^  |  ^  |  ^  |  ^  |
--             __|  |__|  |__|  |__|  |__|  |_
--                      _____________________
--     i_Async ________|
--                           ________________
--     Q0      __________????
--                                   ________
--     o_Sync  _____________________|
--      (Q1)
--
-- Dependencies: x
-- Note: x
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Sync_2FF is
    port(
        i_Clk    : in std_logic; 
        i_Async  : in std_logic;
        i_Reset  : in std_logic;
        o_Sync   : out std_logic);
end Sync_2FF;

architecture behavior of Sync_2FF is

	signal r_sync_1,r_sync_2 : std_logic := '0';

begin
    
    o_Sync <= r_sync_2;

    process(i_Clk)
    begin
        if (rising_edge(i_Clk)) then
            if (i_Reset = '0') then            
                r_sync_1 <= '0';
                r_sync_2 <= '0';
            else
                r_sync_1 <= i_Async;
                r_sync_2 <= r_sync_1;
            end if;    
                
        end if;
    end process; 

end behavior; 