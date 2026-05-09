-------------------------------------------------------------------------------
-- File     : uart_tx_status.vhd
-- Author   : Jampag
-- Date     : 2026 may 05
-- Revision : 2.0
-- Description:
--   UART status transmitter example.
--   The module periodically transmits the value of an input status bus
--   in ASCII hexadecimal format.
--
--   The input bus width is defined by the generic G_DATA_BYTES:
--
--     i_Data width = G_DATA_BYTES * 8 bits
--
--   Each input byte is converted into two ASCII hexadecimal characters.
--   The message is terminated with CR and LF characters.
--
--   The transmission can be started in two different ways, selected by the
--   generic G_TRIGGER:
--
--     G_TRIGGER = false  -> message is transmitted once every second
--     G_TRIGGER = true   -> message is transmitted on the rising edge of i_DV
--
-- Block Diagram:         

-- Block Diagram:
--                ____________________________________________________
--               |                                                    |
--      i_Clk -->|----+---------------+------------------+            |
--               |    |               |                  |            |
--               |    v               |                  v            |
--               |   __________       |        __________________     |
--      i_DV --> |--|          |      |       |                  |    |
--               |  | Trigger  |------|------>|tx_start  UART TX |--->|- o_TX
--               |  | logic    |      v       |__________________|    |
--               |  |__________|  _____________________      ^        |
--               |               |                     |     |        |
--  i_Data[x:0]->|-------------->|i_Data[x:0]          |     |        |
--               |               |    |                |     |        |
--               |               |    V                |     |        |
--               |               | hex_to_ascii        |     |        |
--               |               |     |               |     |        |
--               |               |     '--> msg_array()|-----'        |
--               |               |_____________________|              |
--               |____________________________________________________|
--
-- Timing Example: x
-- Note: 
--   G_DATA_BYTES defines the number of input bytes to display.
--   G_DUMMY_BITS defines the number of idle bit-times inserted after each
--   UART frame format:
--    8 data bits, no parity, 1 stop bit.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity uart_tx_status is
    generic (
        G_CLOCK_FREQ : integer := 100_000_000; 
        G_BAUD_RATE  : integer := 115_200;    -- Baud rate UART
        G_DATA_BYTES : integer := 1;          -- Input Byte 
        G_DUMMY_BITS : integer := 2; -- n of dummy bit after each UART TX byte
        G_TRIGGER    : boolean := true -- true= risig edge external trigger 
    );
    port (
        i_Clk  : in  std_logic;
        i_Data : in  std_logic_vector((G_DATA_BYTES * 8) - 1 downto 0 );  -- Input pin state
        o_TX   : out std_logic;
        i_DV   : in  std_logic  
    );
end uart_tx_status;

architecture Behavioral of uart_tx_status is

    -- Constants
    constant UART_FRAME_BITS : integer := 10;
    constant BAUD_MAX    : integer := G_CLOCK_FREQ / G_BAUD_RATE;
    constant BAUD_CNT_BITS : integer := integer(ceil(log2(real(BAUD_MAX))));   
    constant MSG_LENGTH    : integer := (G_DATA_BYTES * 2) + 2;

    constant SEC_CNT_BITS  : integer := integer(ceil(log2(real(G_CLOCK_FREQ))));
    constant MAX_SEC_CNT : unsigned(SEC_CNT_BITS - 1 downto 0) := to_unsigned(G_CLOCK_FREQ-1, SEC_CNT_BITS);

    -- Counters
    signal baud_cnt : unsigned(BAUD_CNT_BITS - 1 downto 0) := (others => '0');
    signal sec_cnt  : unsigned(SEC_CNT_BITS  - 1 downto 0) := (others => '0');

    -- Signals
    signal tx_start   : std_logic := '0';
    signal r_DV_prev : std_logic := '0';

    signal baud_tick    : std_logic := '0';

    signal bit_index    : integer range 0 to UART_FRAME_BITS + G_DUMMY_BITS - 1 := 0;
    signal sending    : std_logic := '0';

    signal r_TX       : std_logic := '1';
    signal r_data     : std_logic_vector(7 downto 0) := (others => '0');
    signal message_index  : integer range 0 to MSG_LENGTH - 1 := 0;
    
    -- Function nibble to ASCII
    subtype nibble_t is std_logic_vector(3 downto 0);
    subtype byte_t   is std_logic_vector(7 downto 0);

    function hex_to_ascii(nibble : nibble_t)
        return byte_t is
    begin
        case nibble is
            when "0000" => return x"30"; -- '0'
            when "0001" => return x"31"; -- '1'
            when "0010" => return x"32"; -- '2'
            when "0011" => return x"33"; -- '3'
            when "0100" => return x"34"; -- '4'
            when "0101" => return x"35"; -- '5'
            when "0110" => return x"36"; -- '6'
            when "0111" => return x"37"; -- '7'
            when "1000" => return x"38"; -- '8'
            when "1001" => return x"39"; -- '9'
            when "1010" => return x"41"; -- 'A'
            when "1011" => return x"42"; -- 'B'
            when "1100" => return x"43"; -- 'C'
            when "1101" => return x"44"; -- 'D'
            when "1110" => return x"45"; -- 'E'
            when "1111" => return x"46"; -- 'F'
            when others => return x"3F"; -- '?'
        end case;
    end function;    

    -- UART message
    type msg_array is array (0 to MSG_LENGTH - 1) of std_logic_vector(7 downto 0);
    signal message : msg_array := (others => x"00");
    
    

begin

    o_TX <= r_TX;

    --------------------------------------------------------------------
    -- Trigger
    --------------------------------------------------------------------
    
    g_one_sec_trigger : if G_TRIGGER = false generate 
    begin 
        process(i_Clk)
        begin
            if rising_edge(i_Clk) then
    
                if sec_cnt = MAX_SEC_CNT then
                    sec_cnt      <= (others => '0');
                    tx_start <= '1';
                else
                    sec_cnt      <= sec_cnt + 1;
                    tx_start <= '0';
                end if;
    
            end if;
        end process;
    end generate g_one_sec_trigger;
    
    g_trigger_ext : if G_TRIGGER = true generate 
    begin 
        trigger:process(i_Clk)
        begin
            if rising_edge(i_Clk) then
        
                r_DV_prev <= i_DV;
                
                tx_start <= i_DV and not r_DV_prev;

            end if;
        end process;      
    end generate g_trigger_ext;
    
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
    -- Update UART message from i_Data
    --------------------------------------------------------------------
    process(i_Clk)
        variable nibble_h_msb : integer;
        variable nibble_h_lsb : integer;
        variable nibble_l_msb : integer;
        variable nibble_l_lsb : integer;
    begin
        if rising_edge(i_Clk) then
    
            for i in 0 to G_DATA_BYTES - 1 loop
    
                -- Calculate nibble indexes for byte i
                -- The byte order is MSB first.
                nibble_h_msb := ((G_DATA_BYTES - i) * 8) - 1;
                nibble_h_lsb := nibble_h_msb - 3;
    
                nibble_l_msb  := nibble_h_lsb - 1;
                nibble_l_lsb  := nibble_l_msb - 3;
    
                -- Convert high nibble to ASCII HEX
                message(i * 2) <= hex_to_ascii(i_Data(nibble_h_msb downto nibble_h_lsb));
    
                -- Convert low nibble to ASCII HEX
                message((i * 2) + 1) <= hex_to_ascii(
                    i_Data(nibble_l_msb downto nibble_l_lsb)
                );
    
            end loop;
    
            -- End of line
            message(MSG_LENGTH - 2) <= x"0D"; -- Carriage Return
            message(MSG_LENGTH - 1) <= x"0A"; -- Line Feed
    
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

                if tx_start = '1' then
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
                        
                        if ( message_index = MSG_LENGTH -1 ) then
                            sending   <= '0';
                        else                        
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
