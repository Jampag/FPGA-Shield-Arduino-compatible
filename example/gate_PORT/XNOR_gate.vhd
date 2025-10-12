----------------------------------------------------------------------------------
-- Autor: Jampag
-- 
-- Create Date: 10.10.2025 
-- Design Name: XNOR_gate`
-- Module Name: XNOR_gate
-- Project Name: XNOR_gate
-- Target Devices: MODULO FPGA Ver3
-- Tool Versions: 2024.2
-- Description:  
--      A simple XOR gate project
--             ______
--      A ----\\     \
--             || XOR )o--- Y
--      B ----//_____/
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
entity XNOR_gate is
    port (
        A		: in std_logic; 
        B		: in std_logic;
        Y		: out std_logic);
end XNOR_gate;

-- Architecture
architecture Behavioral of XNOR_gate is

-- Begin Architecture
begin

    -- Signal Assignments
    Y <= NOT (A XOR B);
    
end Behavioral;
