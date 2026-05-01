-------------------------------------------------------------------------------
-- File     : LFSR_3.vhd
-- Author   : Jampag
-- Date     : 2026 april 30
-- Revision : 1.0 
-- Description:
--   LFSR 3-Bit with XNOR gate port, serial OUT
-- Block Diagram:
--
--                         ____   
--                        /    ||-------------------.
--          .-----------o( XNOR||                   |
--          |             \____||-----.             |
--          |  ________     ________  |   ________  |
--          '-|D     Q |---|D     Q |-+--|D     Q |-+-- o_Data
--          .-|>       | .-|>       |  .-|>       |
--          | |________| | |________|  | |________|
-- i_Clk ___|____________|_____________|
--     
--       __________________________________________________
--      | Clock cycle | LFSR data (bin) |  LFSR data (dec) |
--      |-------------+-----------------+------------------|
--      | 0           | 000             | 0                |
--      | 1           | 001             | 1                |
--      | 2           | 011             | 3                |
--      | 3           | 110             | 6                |
--      | 4           | 101             | 5                |
--      | 5           | 010             | 2                |
--      | 7           | 100             | 4                |
--      | 8           | 000             | 0                |
--      +--------------------------------------------------+
--
-- Dependencies: x
-- Note: referance XAPP052.PDF  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LFSR_3 is
    port (
        i_Clk  : in  std_logic;
        o_Data : out std_logic
    );
end entity LFSR_3;

architecture RTL of LFSR_3 is

    signal r_LFSR : std_logic_vector(2 downto 0) := (others => '0');
    signal w_XNOR : std_logic;

begin

    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            r_LFSR <= r_LFSR(1 downto 0) & w_XNOR;
        end if;
    end process;

    -- Feedback XNOR bit2 and bit1; referance XAPP052.PDF  
    w_XNOR <= r_LFSR(2) xnor r_LFSR(1);

    -- Output serial
    o_Data <= r_LFSR(2);

end architecture RTL;