-------------------------------------------------------------------------------
-- File     : LFSR_24_led.vhd
-- Author   : Jampag
-- Date     : 2026 april 30
-- Revision : 1.0 
-- Description:
--   LFSR 24-Bit with XNOR gate port, serial OUT and toggle LED every r_LFSR=0
-- Block Diagram:
--
--                                             ________     
--          .---------------------------------|>     Q |----------[>] o_LED
--          |                               .-|T     R |--i_Reset
--  i_Clk---+                               | |________|
--          |  _____________     ________   | 
--          '-|>   r_LFSR(x)|---|  24    |  |  
--            |    r_LFSR(1)|---|  input |--'
--          .-|R   r_LFSR(0)|-+-|  LUT   |
--          | |_____________| | |________|
-- i_Reset__|                 '-----------------------------------[>] o_Data
--     
-- Dependencies: x
-- Note: 
--  Referance XAPP052.PDF  
--  LFSR 24-bit: 2^24-1= 16777215/100MHz-> 0,169s*2-> 0.335s-> 1/0.335=2,98Hz
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LFSR_24_led is
    port (
        i_Clk   : in  std_logic;
        i_Reset : in  std_logic;
        o_Data  : out std_logic;
        o_LED   : out std_logic
    );
end entity LFSR_24_led;

architecture RTL of LFSR_24_led is

    signal r_LFSR : std_logic_vector(23 downto 0) := (others => '0');
    signal w_XNOR : std_logic;
    signal r_LED  : std_logic := '0';

begin

    process(i_Clk)
    begin
        if rising_edge(i_Clk) then

            if i_Reset = '0' then
                r_LFSR <= (others => '0');
                r_LED  <= '0';
            else
                r_LFSR <= r_LFSR(22 downto 0) & w_XNOR;
                
                -- Toggle LED when LFSR = 000...000
                if r_LFSR = (r_LFSR'range => '0') then
                    r_LED <= not r_LED;
                end if;

            end if;
        end if;
    end process;

    -- Tap: bit23, bit22, bit21, bit16; referance XAPP052.PDF  
    w_XNOR <= r_LFSR(23) xnor r_LFSR(22) xnor r_LFSR(21) xnor r_LFSR(16);

    -- Output serial
    o_Data <= r_LFSR(0);

    -- LED toggled
    o_LED <= r_LED;

end architecture RTL;