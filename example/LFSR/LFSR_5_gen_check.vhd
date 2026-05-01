-------------------------------------------------------------------------------
-- File     : LFSR_5_gen_check.vhd
-- Author   : Jampag
-- Date     : 2026 april 30
-- Revision : 1.0 
-- Description:
--   LFSR 5-Bit with XNOR gate port, serial OUT
-- Block Diagram:
--                                                ____          .-G_LATCH_ERROR  
-- i_Data----------------------------------------|    \     ____|___ 
--                                               | XOR )---|D  CE Q |-------- o_Error
--                                             .-|____/  .-|>       |
--                                             |         | |_____R__|
--                                             |    i_Clk'       |   
--                        ____                 |          i_Reset'
--                       /    ||---------------+----------------------------.
--         .-----------o( XNOR||                                            |
--         |             \____||------------------.                         |
--         |  ________     ________     ________  |  ________     ________  |
--         '-|D     Q |---|D     Q |---|D     Q |-+-|D     Q |---|D     Q |-+- o_Data
--         .-|>       | .-|>       | .-|>       | .-|>       | .-|>       |
--         | |_______R| | |_____R__| | |______R_| | |_____R__| | |_____R__|
--         |         |  |       |    |        |   |       |    |       |
-- i_Reset-|---------+--|-------+----|--------+---|-------+----|-------'         
-- i_Clk --+------------+------------+------------+------------+
--     
-- Dependencies: x
-- Note: x
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LFSR_5_gen_check is
    generic(
        G_LATCH_ERROR : boolean := true -- true = latched, false = realtime
    );
    port (
        i_Clk   : in  std_logic;
        i_Reset : in  std_logic;
        o_Data  : out std_logic;
        i_Data  : in  std_logic;
        o_Error : out std_logic
    );
end entity LFSR_5_gen_check;

architecture RTL of LFSR_5_gen_check is

    signal r_LFSR  : std_logic_vector(4 downto 0) := (others => '0');
    signal w_XNOR  : std_logic;
    signal r_Error : std_logic;  

begin

    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Reset = '0' then
                r_LFSR <= (others => '0');
                r_Error <= '0';
            else
                if (i_Data /= r_LFSR(4)) then
                    r_Error <= '1';
                elsif (G_LATCH_ERROR = false) then
                    r_Error <= '0';
                end if;
                
                r_LFSR <= r_LFSR(3 downto 0) & w_XNOR;
            end if;
        end if;
    end process;

    -- Feedback XNOR bit4 and bit2
    w_XNOR <= r_LFSR(4) xnor r_LFSR(2);

    -- Output
    o_Data <= r_LFSR(4);   
    o_Error <= r_Error;

end architecture RTL;