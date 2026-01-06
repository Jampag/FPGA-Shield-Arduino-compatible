-------------------------------------------------------------------------------
-- File : FDPE_stub_bd
-- Autor : Jampag
-- Data : 2026-01-06
-- Description: Primitive Xilinx UG768
--
--        P ____
--            __|___
-- Data  ----|      |---- Q
--           | DFF  |     
--  Clk  ----|      |
--           |      |
--   CE  ----|______|
--
--Note :
--Example
--"...\Xilinx\Vivado\2024.2\ids_lite\ISE\vhdl\src\unisims\primitive\FDPE.vhd"
-- Block Design does not handle 'bit' well during wrapper creation... use
-- std_logic instead.

----- CELL FDPE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Libreria per le primitive Xilinx
library UNISIM;
use UNISIM.VComponents.all;

entity FDPE_stub is
  generic(
    INIT : bit  := '1'
    );

  port(
    Q   : out std_logic;
    C   : in std_logic;
    CE  : in std_logic;
    D   : in std_logic;
    PRE : in std_logic
    );
end FDPE_stub;

architecture behavior of FDPE_stub is


begin

    FDPE_inst : FDPE
    generic map (
        INIT => INIT
    )
    port map (
        Q   => Q,   -- Data output
        C   => C,   -- Clock input
        CE  => CE,  -- Clock enable input
        PRE => PRE, -- Synchronous reset input
        D   => D    -- Data input
    );

end behavior;


