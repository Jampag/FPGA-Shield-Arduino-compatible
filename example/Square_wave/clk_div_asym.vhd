-------------------------------------------------------------------------------
-- File     : clk_div_asym.vhd
-- Author   : Jampag
-- Date     : 2026 August 23
-- Revision : 1.0 
-- Description: Programmable asynnetric clock divider.
--              Output stays HIGH for (i_High + 1) clock cycles.
--              Output stays LOW  for (i_Low  + 1) clock cycles.
--
--              Frequency calc:
--               f_out = f_clk / (i_High + 1) + (i_Low + 1)
--
--              Examples:
--               Divide by 3: i_High = 0 (1 clk), i_Low = 1 (2 clks)
--               Divide by 5: i_High = 1 (2 clk), i_Low = 2 (3 clks)
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
--                 ---------------------------------------------
--     i_High()-->|                 LUT MATRIX                  |
--     i_Low() -->|                              TC             |
--                 ---------------------------------------------
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

entity clk_div_asym is
    Generic (
        DIV_WIDTH : integer := 8
    );
    Port (
        i_Clk   : in  std_logic;
        i_Reset : in  std_logic;
        i_High  : in  std_logic_vector(DIV_WIDTH - 1 downto 0);
        i_Low  : in  std_logic_vector(DIV_WIDTH - 1 downto 0);
        o_DIV   : out std_logic
    );
end entity;

architecture Behavioral of clk_div_asym is

    signal r_Counter : unsigned(DIV_WIDTH - 1 downto 0) := (others => '0');
    signal r_DIV     : std_logic := '0';

begin

    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Reset = '0' then
                r_Counter <= (others => '0');
                r_DIV     <= '0';
                
            elsif r_DIV = '0' then
            
                if r_Counter >= unsigned(i_Low) then
                    r_Counter <= (others => '0');
                    r_DIV     <= '1';
                else
                    r_Counter <= r_Counter + 1;
                end if;
                
            else
            
                if r_Counter >= unsigned(i_High) then
                    r_Counter <= (others => '0');
                    r_DIV     <= '0';
                else
                    r_Counter <= r_Counter + 1;
                end if;                
            
            
            end if;
            
        end if;
    end process;

    o_DIV <= r_DIV;

end architecture;