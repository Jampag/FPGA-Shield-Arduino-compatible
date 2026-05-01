-------------------------------------------------------------------------------
-- File     : LFSR_5.vhd
-- Author   : Jampag
-- Date     : 2026 april 30
-- Revision : 1.0 
-- Description:
--   LFSR 5-Bit with XNOR gate port, serial OUT
-- Block Diagram:
--
--                        ____   
--                       /    ||--------------------------------------------.
--         .-----------o( XNOR||                                            |
--         |             \____||------------------.                         |
--         |  ________     ________     ________  |  _______      ________  |
--         '-|D     Q |---|D     Q |---|D     Q |-+-|D     Q |---|D     Q |-+- o_Data
--         .-|>       | .-|>       | .-|>       | .-|>       | .-|>       |
--         | |_______R| | |_____R__| | |______R_| | |_____R__| | |_____R__|
--         |         |  |       |    |        |   |       |    |       |
-- i_Reset-|---------+--|-------+----|--------+---|-------+----|-------'         
-- i_Clk --+------------+------------+------------+------------+
--     
-- Dependencies: x
-- Note: referance XAPP052.PDF  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LFSR_5 is
    port (
        i_Clk   : in  std_logic;
        i_Reset : in  std_logic;
        o_Data  : out std_logic
    );
end entity LFSR_5;

architecture RTL of LFSR_5 is

    signal r_LFSR : std_logic_vector(4 downto 0) := (others => '0');
    signal w_XNOR : std_logic;

begin

    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Reset = '0' then
                r_LFSR <= (others => '0');
            else
                r_LFSR <= r_LFSR(3 downto 0) & w_XNOR;
            end if;
        end if;
    end process;

    -- Feedback XNOR bit4 and bit2; ; referance XAPP052.PDF  
    w_XNOR <= r_LFSR(4) xnor r_LFSR(2);

    -- Output serial
    o_Data <= r_LFSR(4);

end architecture RTL;