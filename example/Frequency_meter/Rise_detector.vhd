-------------------------------------------------------------------------------
-- File     : Rise_detector.vhd
-- Author   : Jampag
-- Date     : 2026 October 21
-- Revision : 1.0 
-- Description: Detects a rising transition on i_IN and generates a pulse.
--              It is asserted for approximately one clock cycle.
--              The pulse width is one clock-cycle if "i_IN" is driven
--              by DFF. 
--
-- Block Diagram:    
--                  ______________     _____
--                 |  _______     '---|AND  \______ o_Pulse
--          i_IN --+-|D     Q|-------O|_____/
--                   |  DFF  |
--          i_CK ----|CK     |
--                   |_______|
--
-- Timing Example:
--                __    __    __    __    __    __    __  
--       i_CK    ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  
--             __|  |__|  |__|  |__|  |__|  |__|  |__|  |__  
--                       _________________       
--        i_IN _________^                 |________________
--                             _________________
--          Q  _______________|                 |__________
--                       _____            
--     o_Pulse _________|     |____________________________
--
-- Dependencies: x
-- Note: It is good practice to add a DFF after the AND combinational logic 
--       to prevent glitches from propagating to downstream logic.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Rise_detector is
    port(
        i_CK     : in std_logic; 
        i_IN     : in std_logic;
        o_Pulse  : out std_logic);
end Rise_detector;

architecture behavior of Rise_detector is

	signal Q_reg : std_logic := '0';

begin
    
    o_Pulse <= i_IN and (not Q_reg);  

    process(i_CK)
    begin
        if (rising_edge(i_CK)) then
            Q_reg <= i_IN;
        end if;
    end process; 

end behavior; 