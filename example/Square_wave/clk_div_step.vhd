-------------------------------------------------------------------------------
-- File     : clk_div_step.vhd
-- Author   : Jampag
-- Date     : 2026 August 21
-- Revision : 1.0 
-- Description: Programmable toggle clock divider.
--              Output toggles every (i_DIV + 1) clock cycles.
--
--              Frequency calculation:
--                  f_out = f_Clk / (2 * (i_DIV + 1))
--
--              Example:
--                  i_DIV = 1 -> Toggles every 2 clocks
--                           f_out = f_Clk / 4
--
-- Block Diagram: x
--
-- i_Clk -----+--------------------+--------------------+
-- i_Reset -+-|------------------+-|------------------+ |
--          | |                  | |                  | |
--        __|_|_               __|_|_               __|_|_
--       |D     |             |D     |             |D     |
--       | DFF0 |──• Q0       | DFF1 |──• Q1       | DFF2 |──• Q2 ...
--       |______|  | (/2)     |______|  | (/4)     |______|  | (/8)
--                 |                    |                    |
--                 v                    v                    v
--                ---------------------------------------------
--       i_DIV-->|                 LUT MATRIX                  |
--               |                              TC             |
--                ---------------------------------------------
--                                               |
--                                               |   ______           
--                                               '--|T     |          
--                                                  | TFF  |──> o_Div
--                                          i_Clk-- |______|    
-- Dependencies: x
-- Note: x


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_div_step is
    Generic (
        DIV_WIDTH : integer := 8
    );
    Port (
        i_Clk   : in  std_logic;
        i_Reset : in  std_logic;
        i_DIV   : in  std_logic_vector(DIV_WIDTH - 1 downto 0);
        o_DIV   : out std_logic
    );
end entity;

architecture Behavioral of clk_div_step is

    signal r_Counter : unsigned(DIV_WIDTH - 1 downto 0) := (others => '0');
    signal r_DIV     : std_logic := '0';

begin

    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Reset = 0' then
                r_Counter <= (others => '0');
                r_DIV     <= '0';
                
            elsif r_Counter >= unsigned(i_DIV) then
                r_Counter <= (others => '0');
                r_DIV     <= not r_DIV;
                
            else
                r_Counter <= r_Counter + 1;
            end if;
        end if;
    end process;

    o_DIV <= r_DIV;

end architecture;
