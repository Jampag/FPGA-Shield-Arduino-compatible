----------------------------------------------------------------------------------
-- Autor: Jampag
-- 
-- Create Date: 10.10.2025 
-- Design Name: OR_gate`
-- Module Name: OR_gate
-- Project Name: OR_gate
-- Target Devices: MODULO FPGA Ver3
-- Tool Versions: 2024.2
-- Description:  
--      A simple OR gate project
--             ______
--      A ----\      \
--             | OR   )---- Y
--      B ----/______/
-- 
-- Dependencies: 
-- Additional Comments:x
-- 
----------------------------------------------------------------------------------
-- Library 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entity Declaration
entity OR_gate is
    port (
        A		: in std_logic; 
        B		: in std_logic;
        Y		: out std_logic);
end OR_gate;

-- Architecture
architecture Behavioral of OR_gate is

-- Begin Architecture
begin

    -- Signal Assignments
    Y <= (A OR B);
    
end Behavioral;
