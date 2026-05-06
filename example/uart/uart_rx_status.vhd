-------------------------------------------------------------------------------
-- File     : uart_rx_status.vhd
-- Author   : Jampag
-- Date     : 2026 may 02
-- Revision : 1.0
-- Description:
--   UART status receiver.
--   The module receives ASCII hexadecimal characters from the UART input i_Rx
--   and converts them into binary data on o_Data.
--
--   The output data width is defined by the generic G_DATA_BYTES:
--
--     o_Data width = G_DATA_BYTES * 8 bits
--
--   Each output byte is built from two received ASCII hexadecimal characters.
--   Each received ASCII character is converted into a 4-bit hexadecimal nibble
--   using the ascii_to_hex function.
--
--   The internal buffer is updated as a nibble shift register. Every new
--   received nibble is appended to the low side of the buffer, while the
--   previous content is shifted toward the high side.
--
--   Example:
--     received ASCII characters: '5' then '1'
--     converted nibbles        :  x5  then x1
--     resulting o_Data byte    :  x51
--
--   o_Buf_Ready indicates that the configured number of ASCII characters has
--   been received and the output data buffer has been updated.
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

entity uart_rx_status is
    generic(
        G_CLOCK_FREQ : integer := 100_000_000; 
        G_BAUD_RATE  : integer := 115_200;    -- Baud rate UART
        G_DATA_BYTES : integer := 1
    );
    Port (
        i_Clk   : in  std_logic; 
        i_RX    : in  std_logic; 
        o_Data  : out std_logic_vector((G_DATA_BYTES * 8) - 1 downto 0);
        o_Buf_Ready    : out std_logic -- Buffer Ready, index 0
    );
end uart_rx_status;

architecture Behavioral of uart_rx_status is
    
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
    signal baud_cnt     : unsigned(BAUD_CNT_BITS - 1 downto 0) := (others => '0');
    signal bit_index    : integer range 0 to 9 := 0;    
    signal byte_index   : integer range 0 to (G_DATA_BYTES * 2) - 1 := 0;
        

    -- Signals
    signal r_Data      : std_logic_vector(7 downto 0) := (others => '0');
    signal r_Rx        : std_logic := '0';
    signal r_start_bit_detected : std_logic := '0';
    signal r_DV        : std_logic := '0';
    signal r_Buff_HEX  : std_logic_vector((G_DATA_BYTES * 8) - 1 downto 0) := (others => '0');
    signal r_Data_Out  : std_logic_vector((G_DATA_BYTES * 8) - 1 downto 0) := (others => '0');
    signal r_DV_prev   : std_logic := '0';
    signal r_Buf_Ready      : std_logic := '0';

    -- Function ASCII to nibble
    subtype byte_t   is std_logic_vector(7 downto 0);
    subtype nibble_t is std_logic_vector(3 downto 0);
    
    function ascii_to_hex(ascii_char : byte_t)
        return nibble_t is
    begin
        case ascii_char is
    
            -- ASCII '0' .. '9'
            when x"30" => return x"0";
            when x"31" => return x"1";
            when x"32" => return x"2";
            when x"33" => return x"3";
            when x"34" => return x"4";
            when x"35" => return x"5";
            when x"36" => return x"6";
            when x"37" => return x"7";
            when x"38" => return x"8";
            when x"39" => return x"9";
    
            -- ASCII 'A' .. 'F'
            when x"41" => return x"A";
            when x"42" => return x"B";
            when x"43" => return x"C";
            when x"44" => return x"D";
            when x"45" => return x"E";
            when x"46" => return x"F";
    
            -- ASCII 'a' .. 'f'
            when x"61" => return x"A";
            when x"62" => return x"B";
            when x"63" => return x"C";
            when x"64" => return x"D";
            when x"65" => return x"E";
            when x"66" => return x"F";
    
            -- Invalid character
            when others => return x"0";
    
        end case;
    end function;


begin

    -- Output
    o_Buf_Ready <= r_Buf_Ready;
    o_Data <= r_Data_Out;

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
    -- Copy received byte and convert into buffer
    ------------------------------------------------------------
    process(i_Clk)       
    begin
        if rising_edge(i_Clk) then
    
            r_DV_prev <= r_DV;
    
            if r_DV = '1' and r_DV_prev = '0' then
                r_Buf_Ready <= '0';
                
                
                r_Buff_HEX <= r_Buff_HEX((G_DATA_BYTES * 8) - 5 downto 0) & ascii_to_hex(r_Data);  
                
                -- Byte index            
                if byte_index = (G_DATA_BYTES * 2) - 1 then
                    byte_index  <= 0;
                    r_Buf_Ready <= '1'; -- Buffer empty or full
                else
                    byte_index <= byte_index + 1;
                end if;

            end if;

            -- Copy Buffer
            if r_Buf_Ready = '1' then
                r_Data_Out <= r_Buff_HEX;
            end if;
    
        end if;
    end process; 


end Behavioral;
