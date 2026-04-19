-------------------------------------------------------------------------------
-- File : DIV_by_2_DFF.vhd
-- Author : Jampag
-- Date : 2025-01-25             
-- Description: Clk DIV by 2 
--                 __
--                /  |
--         ┌----o(NOT|-----┐
--         |      \__|     |
--         |               |
--         |    ______     |
--         •---|D     |----•- Q
--             | DFF  |                  
--     Clk ----|______|
--
--         __    __    __    __    __    __ 
--  Clk   ^  |  ^  |  ^  |  ^  |  ^  |  ^  |
--      __|  |__|  |__|  |__|  |__|  |__|  |__
--         _____       _____       _____ 
--  Q     |     |     |     |     |     |
--      __|     |_____|     |_____|     |
--
--
-------------------------------------------------------------------------------

-- Library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entity Declaration
entity DIV2 is
    port(
        Clk     : in std_logic;
        Q       : out std_logic);
end DIV2;

-- Architecture
architecture behavior of DIV2 is

	-- Defined Signals
	signal Q_reg : std_logic := '0';

-- Begin Architecture
begin

    -- Signal Assignments
    Q <= Q_reg;

    process(Clk)
    begin
        if (rising_edge(Clk)) then
            Q_reg <= NOT Q_reg;
        end if;
    end process; 
    
end behavior;
