-------------------------------------------------------------------------------
-- File : DFF_simple.vhd
-- Author : Jampag
-- Data : 2025-11-28             
-- Description: DFF 
--              ______     
--       D ----|D     |---- Q
--             | DFF  |                  
--      CK ----|______|
--
-- | D | CK | Q         |
-- | X | 0  | no change |
-- | X | 1  | no change |
-- | 0 | ^  | 0         |
-- | 1 | ^  | 1         |
-------------------------------------------------------------------------------
-- Library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entity Declaration
entity DFF_simple is
    port(
        CK     : in std_logic; 
        D      : in std_logic;    -- data in
        Q       : out std_logic); -- data out
end DFF_simple;

-- Architecture
architecture behavior of DFF_simple is

	-- Defined Signals
	signal Q_reg : std_logic := '0'; -- internal register

-- Begin Architecture
begin

    -- Signal Assignments
    Q <= Q_reg;

    process(CK)
    begin
        if (rising_edge(CK)) then
            Q_reg <= D;
        end if;
    end process; 

end behavior; 
