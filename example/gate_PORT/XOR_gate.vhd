----------------------------------------------------------------------------------
-- Author: Jampag
-- 
-- Create Date: 10.10.2025 
-- Design Name: XOR_gate`
-- Module Name: XOR_gate
-- Project Name: XOR_gate
-- Target Devices: MODULO FPGA Ver3
-- Tool Versions: 2024.2
-- Description:  
--      A simple XOR gate project
--             ______
--      A ----\\     \
--             || XOR )---- Y
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
entity XOR_gate is
    port (
        A		: in std_logic; 
        B		: in std_logic;
        Y		: out std_logic);
end XOR_gate;

-- Architecture
architecture Behavioral of XOR_gate is

-- Begin Architecture
begin

    -- Signal Assignments
    Y <= (A XOR B);
    
end Behavioral;
