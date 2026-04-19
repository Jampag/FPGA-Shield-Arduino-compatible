----------------------------------------------------------------------------------
-- Author: Jampag
-- 
-- Create Date: 10.10.2025 
-- Design Name: NOR_gate`
-- Module Name: NOR_gate
-- Project Name: NOR_gate
-- Target Devices: MODULO FPGA Ver3
-- Tool Versions: 2024.2
-- Description:  
--      A simple NOR gate project
--             ______
--      A ----\      \
--             | NOR  )o--- Y
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
entity NOR_gate is
    port (
        A		: in std_logic; 
        B		: in std_logic;
        Y		: out std_logic);
end NOR_gate;

-- Architecture
architecture Behavioral of NOR_gate is

-- Begin Architecture
begin

    -- Signal Assignments
    Y <= NOT (A OR B);
    
end Behavioral;
