-------------------------------------------------------------------------------
-- File     : uart_tx_example.vhd
-- Author   : Jampag
-- Date     : 2026 may 02
-- Revision : 1.0
-- Description:
--   UART transmitter example.
--   The module transmits one 8-bit data value periodically, once every second.
--   The transmitted byte is defined by the generic G_DATA.
--   By default, G_DATA = x"31", which corresponds to the ASCII character '1'.
-- Timing Example:
--
--   UART transmission of ASCII '1'
--
--   G_DATA = x"31" = 0011_0001
--
--                idle  start d0 d1 d2 d3 d4 d5 d6 d7  stop idle
--                  |       |  |  |  |  |  |  |  |  |  |    |
--   o_TX        _ _ ______    __          _____       _______ _ _ 
--                         |__|  |________|     |_____|
--                             1  0  0  0  1  1  0  0   

-- Note: 
--  UART frame format:
--  8 data bits, no parity, 1 stop bit.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity uart_tx_example is
    generic (
        G_CLOCK_FREQ : integer := 100_000_000; 
        G_BAUD_RATE  : integer := 115_200;     -- Baud rate UART
        G_DATA       : std_logic_vector(7 downto 0) := x"31" -- ASCII '1'
    );
    port (
        i_Clk : in  std_logic;
        o_TX  : out std_logic;
        o_dTX  : out std_logic;  -- Debug copy of UART TX line     
    );
end uart_tx_example;

architecture Behavioral of uart_tx_example is

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

    signal bit_index    : integer range 0 to UART_FRAME_BITS - 1 := 0;
    signal sending    : std_logic := '0';

    signal r_TX       : std_logic := '1';
    signal r_data     : std_logic_vector(7 downto 0) := (others => '0');

    

begin

    o_TX <= r_TX;
    o_dTX <= r_TX;

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
                    sending <= '1';
                    r_data <= G_DATA;
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

                    end case;

                    if bit_index = 9 then
                        bit_index <= 0;
                        sending   <= '0';
                    else
                        bit_index <= bit_index + 1;
                    end if;

                end if;

            end if;

        end if;
    end process;

end Behavioral;
