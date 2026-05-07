-------------------------------------------------------------------------------
-- File     : uart_echo.vhd
-- Author   : Jampag
-- Date     : 2026 may 03
-- Revision : 1.0
-- Description:
--   UART echo example.
--   The module receives one UART frame from i_RX, stores the received byte
--   into an internal 8-bit register, and transmits the same byte back on o_TX.
--
--   When the byte has been received, the signal r_DV goes high.
--   This signal is used(trigger) to start the UART transmitter.
--
--   Optional debug outputs:
--     o_dTX : copy of the UART TX signal
--     o_dRX : copy of the UART RX signal
--     o_led : toggles every time a new byte is received
--
-- Block Diagram:
--   
--        .-------------------------------------------------.
--        |                    uart_echo.vhd                |
--        |                                                 |
--        |    ----------      r_Data_rx      ---------     |
--   i_RX |-->| UART RX  |------------------>| UART TX |-+->|o_TX
--        |    ----------                     ---------  |  |
--        |        |                              ^      |  |
--        |        | r_DV                         |      '->|o_dTX
--        |        v                              |         |
--        |    ----------                         |         |
--        |   | Trigger  |---- tx_start ----------'         |
--        |    ----------                                   |
--        |        |                                        |
--        |        v                                        |
--        |    ----------                                   |
--        |   | Toggle   |--------------------------------->|o_led
--        |   | LED      |                                  |
--        |    ----------                                   |
--        |                                                 |
--   i_RX |------------------------------------------------>| o_dRX
--        |                                                 |
--        '-------------------------------------------------'
--
-- Timing Example: x
-- Note: 
--   UART frame format:
--    8 data bits, no parity, 1 stop bit.
--   This is a simple didactic UART echo example.
--   The design does not include a FIFO or receive buffer.
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity uart_echo is
    generic(
        G_CLOCK_FREQ : integer := 100_000_000; 
        G_BAUD_RATE  : integer := 115_200    -- Baud rate UART
    );
    Port (
        i_Clk   : in  std_logic; 
        i_RX    : in  std_logic;
        o_TX    : out std_logic;
        o_dTX   : out std_logic; -- Opt
        o_dRX   : out std_logic;  -- Opt  
        o_led   : out std_logic  -- Opt
    );
end uart_echo;

architecture Behavioral of uart_echo is

    -- Constants
    constant BAUD_TICK  : integer := (G_CLOCK_FREQ / G_BAUD_RATE) - 1 ;
    constant UART_FRAME_BITS : integer := 10;
    constant BAUD_CNT_BITS : integer := integer(ceil(log2(real(BAUD_TICK)))); 
    -- Convert integer to unsigned to compare
    constant BAUD_TICK_U : unsigned(BAUD_CNT_BITS - 1 downto 0) := 
        to_unsigned(BAUD_TICK, BAUD_CNT_BITS); 
    
    --------------
    --    RX    
    --------------
    constant BAUD_TICK_HALF : integer := (BAUD_TICK) / 2;
    constant BAUD_TICK_HALF_U : unsigned(BAUD_CNT_BITS - 1 downto 0) := 
        to_unsigned(BAUD_TICK_HALF, BAUD_CNT_BITS);         
    -- Counters
    signal baud_cnt_rx    : unsigned(BAUD_CNT_BITS - 1 downto 0) := (others => '0');
    signal bit_index_rx   : integer range 0 to UART_FRAME_BITS - 1 := 0;   
    -- Signals
    signal r_Data_rx      : std_logic_vector(7 downto 0) := (others => '0');
    signal r_Rx           : std_logic := '0';
    signal r_start_bit    : std_logic := '0';
    signal r_DV           : std_logic := '0';
    signal led1_reg       : std_logic := '0'; 

    --------------
    --    TX    
    --------------    
    -- Counters
    signal baud_cnt_tx  : unsigned(BAUD_CNT_BITS - 1 downto 0) := (others => '0');
    -- Signals
    signal tick_tx      : std_logic := '0';
    signal bit_index_tx : integer range 0 to UART_FRAME_BITS - 1 := 0;
    signal sending      : std_logic := '0';
    signal tx_start     : std_logic := '0';
    signal r_TX         : std_logic := '1';
    signal r_Data_tx    : std_logic_vector(7 downto 0) := (others => '0');
    -- Trigger TX from RX data-valid
    signal r_DV_prev    : std_logic := '0';    

begin

    -- Output
    o_TX  <= r_TX;
    o_dTX <= r_TX;      -- Opt
    o_dRX <= r_RX;      -- Opt
    o_led <= led1_reg;  -- Opt

    ------------------------------------------------------------
    -- Received UART
    ------------------------------------------------------------
    rx_uart:process(i_Clk)
    begin
        if rising_edge(i_Clk) then
        
            if r_start_bit = '0' then
            
                baud_cnt_rx  <= (others => '0');
                bit_index_rx <= 0;
        
                if i_Rx = '0' then  -- Start bit
                    r_start_bit <= '1';                    
                    r_DV <= '0';
                end if;
                
            else
                
                baud_cnt_rx <= baud_cnt_rx + 1;

                if baud_cnt_rx = BAUD_TICK_HALF_U then
                    r_Rx <= i_Rx;  -- Sampled bit
                end if;

                if baud_cnt_rx = BAUD_TICK_U then -- Baud Bit count
                    baud_cnt_rx <= (others => '0');
                    bit_index_rx <= bit_index_rx + 1;

                    if bit_index_rx >= 1 and bit_index_rx <= 8 then
                        r_Data_rx(bit_index_rx - 1) <= r_Rx;
                    elsif bit_index_rx = 9 then  -- Bit di stop
                        r_start_bit <= '0';
                        r_DV <= '1';
                        bit_index_rx <= 0;
                    end if;
                    
                end if;
            end if;
        end if;
    end process;
    
   
    --------------------------------------------------------------
    -- UART Transmitter
    --------------------------------------------------------------
    tx_uart:process(i_Clk)
    begin
        if rising_edge(i_Clk) then

            if sending = '0' then

                r_TX <= '1'; -- UART line in idle state
                bit_index_tx <= 0;

                if tx_start = '1' then
                    sending <= '1';
                    r_Data_tx <= r_Data_rx;
                end if;

            else

                if tick_tx = '1' then

                    case bit_index_tx is

                        when 0 =>
                            r_TX <= '0';
                            -- Start bit

                        when 1 to 8 =>
                            r_TX <= r_Data_tx(bit_index_tx - 1);
                            -- Data bits, LSB first

                        when 9 =>
                            r_TX <= '1';
                            -- Stop bit

                    end case;

                    if bit_index_tx = 9 then
                        bit_index_tx <= 0;
                        sending   <= '0';
                    else
                        bit_index_tx <= bit_index_tx + 1;
                    end if;

                end if;

            end if;

        end if;
    end process;
    
    baud_tick_tx:process(i_Clk)
    begin
        if rising_edge(i_Clk) then

            if sending = '1' then

                if baud_cnt_tx = BAUD_TICK_U then
                    baud_cnt_tx  <= (others => '0');
                    tick_tx <= '1';
                else
                    baud_cnt_tx  <= baud_cnt_tx + 1;
                    tick_tx <= '0';
                end if;

            else
                baud_cnt_tx  <= (others => '0');
                tick_tx <= '0';
            end if;

        end if;
    end process;    

    trigger:process(i_Clk)
    begin
        if rising_edge(i_Clk) then
    
            r_DV_prev <= r_DV;
    
            if r_DV = '1' and r_DV_prev = '0' then
                tx_start <= '1';
                led1_reg <= not led1_reg;
            else
                tx_start <= '0';
            end if;
    
        end if;
    end process;    
    

end Behavioral;