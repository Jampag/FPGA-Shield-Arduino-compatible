-------------------------------------------------------------------------------
-- File     : uart_rx_example.vhd
-- Author   : Jampag
-- Date     : 2026 may 02
-- Revision : 1.0
-- Description:
--   UART receiver example.
--   The module receives one UART frame from i_Rx and stores the received byte
--   into an internal 8-bit register.
--
--   The received byte is compared with G_COMPARE. If they match, o_led is ON.
--
-- Timing Example: x
-- Note: 
--   UART frame format:
--    8 data bits, no parity, 1 stop bit.
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity uart_rx_example is
    generic(
        G_CLOCK_FREQ : integer := 100_000_000; 
        G_BAUD_RATE  : integer := 115_200;    -- Baud rate UART
        G_COMPARE    : std_logic_vector(7 downto 0) := x"0D"
    );
    Port (
        i_Clk   : in  std_logic; 
        i_Rx    : in  std_logic; 
        o_led   : out std_logic  
    );
end uart_rx_example;

architecture Behavioral of uart_rx_example is
    
    -- Constants
    constant BAUD_TICK  : integer := (G_CLOCK_FREQ / G_BAUD_RATE) - 1 ;
    constant BAUD_CNT_BITS : integer := integer(ceil(log2(real(BAUD_TICK)))); 
    constant BAUD_TICK_HALF : integer := (BAUD_TICK) / 2;

    -- Convert integer to unsigned to compare
    constant BAUD_TICK_U : unsigned(BAUD_CNT_BITS - 1 downto 0) := 
        to_unsigned(BAUD_TICK, BAUD_CNT_BITS); 
    constant BAUD_TICK_HALF_U : unsigned(BAUD_CNT_BITS - 1 downto 0) := 
        to_unsigned(BAUD_TICK_HALF, BAUD_CNT_BITS);         
    
    -- Counters
    signal baud_cnt : unsigned(BAUD_CNT_BITS - 1 downto 0) := (others => '0');
    signal bit_index          : integer range 0 to 9 := 0;    
        

    -- Signals
														  
    signal r_Data             : std_logic_vector(7 downto 0) := (others => '0');
    signal r_Rx               : std_logic := '0';
    signal r_start_bit_detected : std_logic := '0';
    signal r_DV               : std_logic := '0';

    signal led1_reg           : std_logic := '0'; -- Debug

begin

    -- Output
    o_led <= led1_reg; -- Debug

    ------------------------------------------------------------
    -- Received UART
    ------------------------------------------------------------
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
        
            if r_start_bit_detected = '0' then
            
                baud_cnt  <= (others => '0');
                bit_index <= 0;
        
                if i_Rx = '0' then  -- Start bit
                    r_start_bit_detected <= '1';                    
                    r_DV <= '0';
                end if;
                
            else
                
                baud_cnt <= baud_cnt + 1;

                if baud_cnt = BAUD_TICK_HALF_U then
                    r_Rx <= i_Rx;  -- Sampled bit
                end if;

                if baud_cnt = BAUD_TICK_U then -- Baud Bit count
                    baud_cnt <= (others => '0');
                    bit_index <= bit_index + 1;

                    if bit_index >= 1 and bit_index <= 8 then
                        r_Data(bit_index - 1) <= r_Rx;
                    elsif bit_index = 9 then  -- Bit di stop
                        r_start_bit_detected <= '0';
                        r_DV <= '1';
                        bit_index <= 0;
                    end if;
                    
                end if;
            end if;
        end if;
    end process;
    
    ------------------------------------------------------------
    -- If is 0x0D the led is ON
    ------------------------------------------------------------
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
        
           if r_DV = '1' and r_Data = G_COMPARE then
                led1_reg <= '1';               
           else
                led1_reg <= '0';
           end if;
        end if;
    end process;    


end Behavioral;
