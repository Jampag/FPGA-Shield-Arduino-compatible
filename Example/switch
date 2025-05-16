----------------------------------------------------------------------------------
-- Autor: Jampag
-- 
-- Create Date: 14.05.2025 
-- Design Name: Switch led
-- Module Name: swicth
-- Project Name: Switch led
-- Target Devices: MODULO FPGA Ver3
-- Tool Versions: 2024.2
-- Description:  
--      1-When the button is not pressed (SW1) the led (L1) is ON also led (L2) 
--        is OFF
--      2-When the button is not pressed (SW1) the led (L2) is ON also led (L1) 
--        is OFF-- 
-- Dependencies: 
-- Additional Comments:x
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity switch is
    Port (
        L1      : out std_logic ;
        L2      : out std_logic ;
        SW1     : in  std_logic
    );
end switch;

architecture Behavioral of switch is
    signal led_status : std_logic;
    signal led1_status : std_logic;

begin
    L1 <= led_status;
    L2 <= led1_status;

    led_status <= '1' when SW1 = '1' else '0';
    led1_status <= '0' when SW1 = '1' else '1';

end Behavioral;
