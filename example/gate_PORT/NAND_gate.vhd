----------------------------------------------------------------------------------
-- Autor: Jampag
-- 
-- Create Date: 10.10.2025 
-- Design Name: NAND_gate`
-- Module Name: NAND_gate
-- Project Name: NAND_gate
-- Target Devices: MODULO FPGA Ver3
-- Tool Versions: 2024.2
-- Description:  
--      A simple NAND gate project
--             ______
--      A ----|      \
--            | NAND  )o---- Y
--      B ----|______/
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
entity NAND_gate is
    port (
        A		: in std_logic; 
        B		: in std_logic;
        Y		: out std_logic);
end NAND_gate;

-- Architecture
architecture Behavioral of NAND_gate is

-- Begin Architecture
begin

    -- Signal Assignments
    Y <= NOT (A AND B);
    
end Behavioral;
