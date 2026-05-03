-------------------------------------------------------------------------------
-- File     : uart_tx_message.vhd
-- Author   : Jampag
-- Date     : 2026 may 02
-- Revision : 1.0
-- Description:
--   UART message transmitter example.
--   The module transmits a fixed ASCII message periodically, once every second.
--   The message is stored in an array of 8-bit values, where each element
--   represents one ASCII character to be transmitted.
--   The transmitted message is:
--     "Stat=0" + CR + LF
--     x"53"  x"74"  x"61"  x"74"  x"3D"  x"31"  x"0D"  x"0A"
--       S      t      a      t      =      1      CR     LF
--   The character '0' can dynamically become '1' reading form the input i_Data.
--   This is obtained by modifying bit 0 of the ASCII character x"30".
--           i_Data = '0' -> x"30" -> ASCII '0'
--           i_Data = '1' -> x"31" -> ASCII '1'
--
-- Timing Example: x
-- Note: 
--  G_MSG_LENGTH defines the number of bytes in the message.
--  G_DUMMY_BITS defines the number of idle bit-times inserted after each
--  UART frame format:
--   8 data bits, no parity, 1 stop bit.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity uart_tx_message is
    generic (
        G_CLOCK_FREQ : integer := 100_000_000; 
        G_BAUD_RATE  : integer := 115_200;     -- Baud rate UART
        G_MSG_LENGTH : integer := 8;          -- Total UART TX byte
        G_DUMMY_BITS : integer := 15  -- n of dummy bit after each UART TX byte
    );
    port (
        i_Clk  : in  std_logic;
        i_Data : in  std_logic;  -- Input pin state
        o_TX   : out std_logic;
        o_dTX  : out std_logic  -- Debug copy of UART TX line     
    );
end uart_tx_message;

architecture Behavioral of uart_tx_message is

    -- Constants
    constant UART_FRAME_BITS : integer := 10;
    constant BAUD_MAX    : integer := G_CLOCK_FREQ / G_BAUD_RATE;
    constant BAUD_CNT_BITS : integer := integer(ceil(log2(real(BAUD_MAX))));   

    constant SEC_CNT_BITS  : integer := integer(ceil(log2(real(G_CLOCK_FREQ))));
    constant MAX_SEC_CNT : unsigned(SEC_CNT_BITS - 1 downto 0) := to_unsigned(G_CLOCK_FREQ-1, SEC_CNT_BITS);

    -- Counters
    signal baud_cnt : unsigned(BAUD_CNT_BITS - 1 downto 0) := (others => '0');
    signal sec_cnt  : unsigned(SEC_CNT_BITS  - 1 downto 0) := (others => '0');

    -- Signals
    signal one_sec_tick : std_logic := '0';

    signal baud_tick    : std_logic := '0';

    signal bit_index    : integer range 0 to UART_FRAME_BITS + G_DUMMY_BITS - 1 := 0;
    signal sending    : std_logic := '0';

    signal r_TX       : std_logic := '1';
    signal r_data     : std_logic_vector(7 downto 0) := (others => '0');
    signal message_index  : integer range 0 to G_MSG_LENGTH - 1 := 0;

    -- UART message
    type msg_array is array (0 to G_MSG_LENGTH - 1) of std_logic_vector(7 downto 0);
    signal message : msg_array := (
        x"53",  -- S
        x"74",  -- t
        x"61",  -- a
        x"74",  -- t
        x"3d",  -- =
        x"30",  -- 0
        x"0d",  -- Carriage Return
        x"0a"  -- Line Feed        
    );
    
    

begin

    o_TX <= r_TX;
    o_dTX <= r_TX;
    message(5)(0) <= i_Data; -- 0->0x30(0) or 1-> 0x31(1)

    --------------------------------------------------------------------
    -- One-second tick generator
    --------------------------------------------------------------------
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then

            if sec_cnt = MAX_SEC_CNT then
                sec_cnt      <= (others => '0');
                one_sec_tick <= '1';
            else
                sec_cnt      <= sec_cnt + 1;
                one_sec_tick <= '0';
            end if;

        end if;
    end process;

    --------------------------------------------------------------------
    -- Baud tick generator, active only during UART transmission  
    --------------------------------------------------------------------
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then

            if sending = '1' then

                if baud_cnt = to_unsigned(BAUD_MAX - 1, BAUD_CNT_BITS) then
                    baud_cnt  <= (others => '0');
                    baud_tick <= '1';
                else
                    baud_cnt  <= baud_cnt + 1;
                    baud_tick <= '0';
                end if;

            else
                baud_cnt  <= (others => '0');
                baud_tick <= '0';
            end if;

        end if;
    end process;

    --------------------------------------------------------------------
    -- UART Transmitter
    --------------------------------------------------------------------
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then

            if sending = '0' then

                r_TX <= '1'; -- UART line in idle state
                bit_index <= 0;

                if one_sec_tick = '1' then
                    sending       <= '1';
                    message_index <= 0;
                    r_data        <= message(0);
                end if;

            else

                if baud_tick = '1' then

                    case bit_index is

                        when 0 =>
                            r_TX <= '0';
                            -- Start bit

                        when 1 to 8 =>
                            r_TX <= r_data(bit_index - 1);
                            -- Data bits, LSB first

                        when 9 =>
                            r_TX <= '1';
                            -- Stop bit
                        when others =>
                            r_TX <= '1';

                    end case;

                    if bit_index = ( 9 + G_DUMMY_BITS) then
                        
                        bit_index <= 0;
                        
                        if ( message_index = G_MSG_LENGTH -1 ) then
                            sending   <= '0';
                        else                        
                            bit_index <= 0;
                            message_index <= message_index + 1;
                            r_data <= message(message_index + 1);
                        end if;
                    
                    else
                        bit_index <= bit_index + 1;
                    end if;

                end if;
            end if;
        end if;
    end process;

end Behavioral;
