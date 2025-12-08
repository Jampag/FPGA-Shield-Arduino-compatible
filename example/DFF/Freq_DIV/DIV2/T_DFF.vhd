-------------------------------------------------------------------------------
-- File : T_DFF.vhd
-- Autor : Jampag
-- Data : 2025-01-30
-- Description: T Flip-Flop with DFF
--
--         ┌──────────────────────────┐ 
--         │   _____                  │
--         └─\\     \                 │
--            ||XOR  )──┐             │
--      T  ──//_____/   │  ______     │      
--                      └─|D     |────• Q   
--                        | DFF  |             
--     Clk ───────────────|______|    
--
--  Truth table 
--  |T|Clk|Q
--  |0| ^ |Block
--  |1| ^ |Toggle
--         __    __    __    __    __    __ 
--  Clk   |  |  |  |  |  |  |  |  |  |  |  |
--      __|  |__|  |__|  |__|  |__|  |__|  |__
--          ________       _____ 
--  T      |        |     |     |
--      ___|        |_____|     |________
--               ___________
--  Q           |           |
--      ________|           |________________
--        B     T     B     T     B     B
--
-------------------------------------------------------------------------------

-- Library
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

-- Entity Declaration
entity T_DFF is
    port (
        T       : in std_logic;
        Clk     : in std_logic;
        Q       : out std_logic);
end T_DFF;

-- Architecture
architecture behavior of T_DFF is

    -- Defined Signals
    signal Q_reg : std_logic := '0';

-- Begin Architecture  
begin

    -- Signal Assignment
    Q <= Q_reg;
    
    
    process(Clk)
    begin
        if rising_edge(Clk) then
            if T = '1' then
                Q_reg <= not Q_reg;
            end if;
        end if;
    end process;
end behavior;

