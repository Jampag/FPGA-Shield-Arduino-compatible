----------------------------------------------------------------------------------
-- Autor: Jampag
-- 
-- Create Date: 10.10.2025 
-- Design Name: AND_gate
-- Module Name: AND_gate
-- Project Name: AND_gate
-- Target Devices: MODULO FPGA Ver3
-- Tool Versions: 2024.2
-- Description:  
--      A simple AND gate project
--                 ______
--          A ----|      \
--                | AND   )---- Y
--          B ----|______/

-- Dependencies: 
-- Additional Comments:x
-- 
----------------------------------------------------------------------------------
-- Library 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entity Declaration
entity AND_gate is
    port (
        A		: in std_logic; 
        B		: in std_logic;
        Y		: out std_logic);
end AND_gate;

-- Architecture
architecture Behavioral of AND_gate is

-- Begin Architecture
begin

    -- Signal Assignments
    Y <= (A AND B);
    
end Behavioral;
