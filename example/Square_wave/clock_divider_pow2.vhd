-------------------------------------------------------------------------------
-- File     : clock_divider_pow2.vhd
-- Author   : Jampag
-- Date     : 2026 August 21
-- Revision : 1.0 
-- Description: Runtime parametric power-of-2 clock divider. Uses a synchronous
--               counter to generate divided clock frequency 2,4,8,16,32 etc.
--               The SEL_WIDTH must be ceil(log2(BIT_DEPTH)).
-- Block Diagram: x
--
-- i_Clk -----+--------------------+--------------------+
-- i_Reset -+-|------------------+-|------------------+ |
--          | |                  | |                  | |
--        __|_|_               __|_|_               __|_|_
--       |D     |             |D     |             |D     |
--       | DFF0 |──• Q0       | DFF1 |──• Q1       | DFF2 |──• Q2 ...
--       |______|  | (/2)     |______|  | (/4)     |______|  | (/8)
--                 |                    |                    |
--                 v                    v                    v
--                ----------------------------------------------
--       i_Sel-->|                      MUX                     |---> o_DIV
--                ----------------------------------------------

-- Dependencies: x
-- Note: x

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider_pow2 is
    Generic (
        -- Number of flip-flops in the counter.
        -- Each stage divides the clock by a power of 2
        --  e.g. BIT_DEPTH = 4 allows division by 2, 4, 8,16.
        BIT_DEPTH : integer := 4; 
        
        -- Bit width of the 'i_Sel' input port.
        -- Must be exactly ceil(log2(BIT_DEPTH)).
        --  e.g. for BIT_DEPTH = 4 -> SEL_WIDTH = 2 (addresses 0 to 3).
        --  e.g. for BIT_DEPTH = 8 -> SEL_WIDTH = 3 (addresses 0 to 7).
        SEL_WIDTH : integer := 2  
    );
    Port (
        i_Clk   : in  std_logic;
        i_Reset : in  std_logic;
        i_Sel   : in  std_logic_vector(SEL_WIDTH - 1 downto 0);
        o_DIV   : out std_logic
    );
end entity;

architecture Behavioral of clock_divider_pow2 is

    signal counter  : unsigned(BIT_DEPTH - 1 downto 0) := (others => '0');

begin

    -- Free-running synchronous counter
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Reset = '0' then
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    o_DIV <= counter(to_integer(unsigned(i_Sel)));

end architecture;
