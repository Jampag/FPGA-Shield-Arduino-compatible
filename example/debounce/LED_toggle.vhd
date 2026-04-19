-------------------------------------------------------------------------------
-- File : LED_toggle
-- Author : Jampag
-- Date : 2026 Jan 25
-- Description: Change led status when btn is relesad
--                __    __    __    __  
--     clk       ^  |  ^  |  ^  |  ^  | 
--             __|  |__|  |__|  |__|  |_
--             ____            ___________
--     SW1         |          |     
--      (D)        |__________|
--             ________             ___________
--     SW1_reg         |           |     
--      (Q)            |___________|
--                  ^^^^
--                    |_toggle led    
--Note :.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Entity 
entity LED_toggle is
    Port (
        L1    : out std_logic;
        clk   : in std_logic;
        SW1   : in std_logic
        );
end LED_toggle; 

-- Architecture
architecture behavior of LED_toggle is
    signal L1_reg    :std_logic := '0'; 
    signal SW1_reg    :std_logic := '0'; 
  begin
    process(Clk)
    begin 
        if rising_edge(Clk) then
            SW1_reg <= SW1;
            if SW1 = '0' and SW1_reg = '1' then
                L1_reg <= not L1_reg;
            end if;
        end if;
    end process;
  L1 <= L1_reg;  
end behavior;

