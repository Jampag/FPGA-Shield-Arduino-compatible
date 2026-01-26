-------------------------------------------------------------------------------
-- File : Debounce_btn
-- Autor : Jampag
-- Data : 2026 Jan 25
-- Description: It a debounce module for button, check input status for 
--  n time(DEBOUNCE_cnt*i_clk) if it stable, the OUT is equal IN status.
--  Set a inital value(INIT_state), if IN is pulluped chose '1' 
--                ________________
--   Clk(100MHz)-|                |
--               |                |
--   SW1  _ \__ -|>unfiltered(IN) |
--               |                |        ↑↑ 
--               | (OUT)filtered >|-- L1  -►|—
--               |________________|  


--Note :.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Entity 
entity Debounce_btn is
    generic(
        DEBOUNCE_cnt    : integer := 100_000;
        INIT_state     : std_logic := '1'
    );
    Port (
        i_clk    : in std_logic;
        i_bounce : in std_logic;
        o_debounce : out std_logic
        );
end Debounce_btn; 

-- Architecture
architecture behavior of Debounce_btn is
    signal r_count    : integer range 0 to DEBOUNCE_cnt-1 := 0; 
    signal r_state    : std_logic := INIT_state; 
    signal init_done  : std_logic := '0'; 
  begin
    process(i_clk)
    begin 
        if rising_edge(i_clk) then
            if init_done = '0' then
                r_state <= i_bounce;
                init_done <= '1';
            else
                if(i_bounce /= r_state and r_count < DEBOUNCE_cnt-1)then
                    r_count <= r_count + 1;
                elsif r_count = DEBOUNCE_cnt-1 then
                    r_state <= i_bounce;
                    r_count <= 0;
                else
                    r_count <= 0;
                end if;
            end if;
        end if;
    end process;
  o_debounce <= r_state;  
end behavior;
