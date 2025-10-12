----------------------------------------------------------------------------------
-- Autor: Jampag
-- 
-- Create Date: 10.10.2025 
-- Design Name: NOT_gate`
-- Module Name: NOT_gate
-- Project Name: NOT_gate
-- Target Devices: MODULO FPGA Ver3
-- Tool Versions: 2024.2
-- Description:  
--      A simple NOT gate project
--             ___
--            |   \
--      A ----|NOT )---- Y
--            |___/
-- 
-- Dependencies: 
-- Additional Comments: x
-- 
----------------------------------------------------------------------------------
-- Library 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entity Declaration
entity NOT_gate is
    port (
        A		: in std_logic;
        Y		: out std_logic);
end NOT_gate;

-- Architecture
architecture Behavioral of NOT_gate is

-- Begin Architecture
begin

    -- Signal Assignments
    Y <= NOT A ;
    
end Behavioral;
