-------------------------------------------------------------------------------
-- File     : Edge_detector.vhd
-- Author   : Jampag
-- Date     : 2026 October 21
-- Revision : 1.0 
-- Description: Detects both rising and falling transitions on i_EdgeDet
--              and generates a pulse.
--              The pulse width is one clock-cycle if "i_EdgeDet" is driven
--              by DFF.
--
-- Block Diagram: 
--     
--                  ______________    ______
--                 |  _______     '--\\ XOR \______ o_Pulse
--     i_EdgeDet --+-|D     Q|-------//_____/
--                   |  DFF  |
--         i_Clk ----|CK     |
--                   |_______|
--     
-- Timing Example:
--                __    __    __    __    __    __    __  
--     i_Clk     ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  
--             __|  |__|  |__|  |__|  |__|  |__|  |__|  |__  
--                       _________________       
--   i_EdgeDet _________^                 v________________
--                             _________________
--          Q  _______________|                 |__________
--                       _____             _____
--     o_Pulse _________|     |___________|     |__________
--
--
-- Dependencies: x
-- Note: It is good practice to add a DFF after the XOR combinational logic 
--       to prevent glitches from propagating to downstream logic.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Edge_detector is
    port(
        i_Clk          : in std_logic; 
        i_EdgeDet : in std_logic;
        o_Pulse       : out std_logic);
end Edge_detector;

architecture behavior of Edge_detector is

	signal Q_reg : std_logic := '0';

begin

    
    o_Pulse <= i_EdgeDet xor Q_reg;
    

    process(i_Clk)
    begin
        if (rising_edge(i_Clk)) then
            Q_reg <= i_EdgeDet;
        end if;
    end process; 

end behavior; 