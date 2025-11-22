-------------------------------------------------------------------------------
-- File : BLINK
-- Autor : Jampag
-- Description: Use a counter that will blink all LEDs on/off at regulare
--              intervals. The blink rate is changeble through the generic
--              of the design. There is an active low reset that when asseted
--              low will cause the count to reset and turn the LEDs off.
-- Board: MODULO FPGA SPARTAN7 rev00
-- Revision: 1.0 22-11-2025
-- Block diagram:
-- 
--                ________________
--  Clk (100MHz)-| counter 27bit  |
--               |                |    _____________________________   ↑↑ 
--  Reset _┴_----|         MAX_VAL|---| | NOT led_reg|    Led_out[0]| -►|—
--               |________________|   |                             |  ↑↑
--                                    |                   Led_out[1]| -►|—
--                                    |_____________________________|
--                                         
--   
-------------------------------------------------------------------------------

-- Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;

-- Entity 
entity BLINK is
    Generic (
        NUM_LED         : integer := 2;
        CLK_RATE        : integer := 100_000_000;  -- 100MHz
        BLINK_RATE      : integer := 2);         -- toogle/second
    Port (
        Led_out         : out std_logic_vector(NUM_LED - 1 downto 0);
        Clk             : in std_logic;
        Reset           : in std_logic);
end BLINK; 

-- Architecture
architecture behavior of BLINK is

    -- Calculate count value to achive 'BLINK_RATE' from generic
    constant MAX_VAL    : integer := CLK_RATE / BLINK_RATE;   
  
    -- Calculate number of bits required to count 'MAX_VAL'
    constant BIT_DEPTH  : integer := integer(ceil(log2(real(MAX_VAL))));
        -- Example: MAX_VAL=12M/2= 6+e6; log2(b)=( log10(b) / log10(2) )
        --          log2(6e6)=22,52 ->ceil(22.52)= 23 bit

    -- Convert integer to unsigned to compare with count_reg
    constant MAX_VAL_U : unsigned(BIT_DEPTH - 1 downto 0) := to_unsigned(MAX_VAL, BIT_DEPTH);
    
    -- Register to hold the current count value init
    signal count_reg    :   unsigned(BIT_DEPTH - 1 downto 0) := (others => '0');
    
    -- Register to hold the value of output LEDs
    signal led_reg      : std_logic_vector(NUM_LED - 1 downto 0) := (others => '0');
    
  begin
    -- Assign output LEDs value
    Led_out <= led_reg;
    
    -- Process that increments the counter every rising clock edge
    count_proc: process(Clk)
    begin 
        if rising_edge(Clk) then
            if ((reset = '0') or ( count_reg = MAX_VAL_U)) then
                count_reg <= (others => '0');
            else 
                count_reg <= count_reg + 1;
            end if;
        end if;
    end process;
    
    -- Process the will toggle the LEDs output everu time the counter
    -- reaches the calculated 'MAX_VAL_U'
    output_proc: process(Clk)
    begin   
        if rising_edge(Clk) then
            if ( count_reg = MAX_VAL_U) then
                led_reg <= NOT led_reg;
            end if;
        end if;
    end process;

end behavior;
