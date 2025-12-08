-------------------------------------------------------------------------------
-- File : FDRE_stub
-- Autor : Jampag
-- Data : 2025-02-01
-- Description: Primitive Xilinx UG953
--            ______
-- Data  ----|      |---- Q
--           | DFF  |     
--  Clk  ----|      |
--           |      |
--   CE  ----|______|
--        R ____|
--


library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Xilinx primitive 
library UNISIM;
use UNISIM.VComponents.all;

entity FDRE_stub is
  generic(
    INIT : bit  := '1' -- Initial value of register ('0' or '1')
    );

  port(
    Q : out std_ulogic;
    C  : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic
    );
end FDRE_stub;

architecture rtl of FDRE_stub is


begin

    FDRE_inst : FDRE
    generic map (
        INIT => INIT 
    )
    port map (
        Q => Q, -- Data output
        C => C, -- Clock input
        CE => CE, -- Clock enable input
        R => R, -- Synchronous reset input
        D => D -- Data input
    );

end rtl;



