-------------------------------------------------------------------------------
-- File     : top-LFSR_generic.vhd
-- Author   : Jampag
-- Date     : 2026 april 30
-- Revision : 1.0 
-- Description:
--  top-level design of LFSR_Generic.vhd module with serial output configuration
-- Block Diagram:
--
-- Dependencies: 
--  LFSR_Generic.vhd
-- Note: 
--  If o_LFSR(x) is not needed, instantiate LFSR_Generic
--   in a top-level entity that exposes only the serial output.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_LFSR is
    port (
        i_Clk   : in  std_logic;
        i_Reset : in  std_logic;
        o_Data  : out std_logic
    );
end entity top_LFSR;

architecture RTL of top_LFSR is

    component LFSR_Generic is
        generic (
            NUM_BITS : integer range 3 to 40 := 5
        );
        port (
            i_Clk   : in  std_logic;
            i_Reset : in  std_logic;
            o_Data  : out std_logic;
            o_LFSR  : out std_logic_vector(NUM_BITS-1 downto 0)
        );
    end component;

begin

    U_LFSR : LFSR_Generic
        generic map (
            NUM_BITS => 5
        )
        port map (
            i_Clk   => i_Clk,
            i_Reset => i_Reset,
            o_Data  => o_Data,
            o_LFSR  => open
        );

end architecture RTL;
