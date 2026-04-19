-------------------------------------------------------------------------------
-- File : FDRE_stub_bd_bd
-- Author : Jampag
-- Date : 2025-12-08
-- Description: Primitive Xilinx UG953
--            ______
-- Data  ----|      |---- Q
--           | DFF  |     
--  Clk  ----|      |
--           |      |
--   CE  ----|______|
--        R ____|
--
--Note :
--Example
--"...\Xilinx\Vivado\2024.2\ids_lite\ISE\vhdl\src\unisims\primitive\FDRE.vhd"
-- Block Design does not handle 'bit' well during wrapper creation... use
-- std_logic instead.

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VComponents.all;

entity FDRE_stub_bd is
  generic(
    INIT : std_logic  := '1'
    );

  port(
    Q : out std_ulogic;
    C  : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic
    );
end FDRE_stub_bd;

architecture rtl of FDRE_stub_bd is

    -- Convesion std_logic to bit
    constant INIT_bit : bit := '1' when INIT = '1' else '0';

begin

    FDRE_inst : FDRE
    generic map (
        INIT => INIT_bit  -- Converted constant
    )
    port map (
        Q => Q, -- Data output
        C => C, -- Clock input
        CE => CE, -- Clock enable input
        R => R, -- Synchronous reset input
        D => D -- Data input
    );

end rtl;


