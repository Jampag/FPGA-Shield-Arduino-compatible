----------------------------------------------------------------------------------
-- Autor: Jampag
-- 
-- Create Date: 25.04.2025 18:14:31
-- Design Name: Macro UART RX and TX
-- Module Name: uart_module - Behavioral
-- Project Name: Test MODULO FPGA Arduino
-- Target Devices: MODULO FPGA Ver3
-- Tool Versions: 2024.2
-- Description:  Il modulo genera una stringa composta da caratteri fissi
--  e caratteri variabili come segue: 
--  RUN-<echo UART 'rx'>-<valore letto da 'sel_vector' default=255>
--      >Il campo <echo UART> è l acquisizione dal pin rx inviato da Arduino
--      >Il campo <sel_vector> da collegare al modulo test_tot.vhd che identifica
--       il pin con problemi se non ci sono problemi il default=255.
-- 
-- Dependencies: test_tot.vhd; pin-out.xdc;Desing test_wrapper.v
-- Revision: 2.00 test_tot.vhd;Version 1 pin-out.xdc
-- Revision 0.01 - File Created
-- Additional Comments:x
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_module is
    Port (
        clk  : in  std_logic;         -- Clock 100 MHz
        tx   : out std_logic;          -- UART TX
        rx   : in std_logic;          -- UART RX
        sel_vector: in std_logic_vector (7 downto 0) := (others => '1')
    );
end uart_module;

architecture Behavioral of uart_module is
    -- Parametri
    constant CLOCK_FREQ     : integer := 100_000_000;
    constant BAUD           : integer := 115200;
    constant BAUD_TICKS     : integer := CLOCK_FREQ / BAUD;
    constant ONE_SEC_TICKS  : integer := CLOCK_FREQ;

    -- Messaggio da inviare
    constant DUMMY_BITS : integer := 14;  -- Numero di bit dummy tra un byte e l altro.
    constant MSG_LENGTH  : integer := 11; -- 
    type message_array is array (0 to MSG_LENGTH - 1) of std_logic_vector(7 downto 0);
    
    -- Definiamo il messaggio che comprende "RUN-x" "SEL xxx" e "\n\r" 
    signal MESSAGE : message_array := (
        x"52",  -- R
        x"55",  -- U
        x"4e",  -- N
        x"2d",  -- -
        x"23",  -- # Carattere ricevuto
        x"2d",  -- -
        x"00",  -- Centinaia di sel (da riempire)
        x"00",  -- Decine di sel (da riempire)
        x"00",  -- Unità di sel (da riempire)
        x"0d",  -- Carriage Return
        x"0a"  -- Line Feed        
    );

    -- Segnali temporali
    signal one_sec_cnt        : integer range 0 to ONE_SEC_TICKS := 0;
    signal start_transmission : std_logic := '0';

    -- Trasmissione
    signal sending       : std_logic := '0';
    signal char_index    : integer range 0 to MSG_LENGTH - 1 := 0;
    signal bit_index     : integer range 0 to 9 + DUMMY_BITS := 0;
    signal baud_cnt      : integer range 0 to BAUD_TICKS := 0;
    signal baud_tick     : std_logic := '0';

    -- UART TX
    signal tx_reg        : std_logic := '1';
    signal current_byte  : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Ricezione
    signal baud_cnt_rx          : integer range 0 to BAUD_TICKS := 0;
    signal rx_sampled        : std_logic := '1';
    signal start_bit_detected: std_logic := '0';
    signal bit_index_rx         : integer range 0 to 9 := 0;
    signal rx_data           : std_logic_vector(7 downto 0) := "00100011"; -- default #
    signal flag_rx           : std_logic := '0';
    
begin
    tx  <= tx_reg;

    -- Conversione di sel in ASCII ("076" ad esempio)
    process(clk)
        variable sel : integer := 999;  -- Può andare fino a 999
        
    begin
        if rising_edge(clk) then
            if sending = '1' then
            
                MESSAGE(4) <= rx_data; -- Data from RX uart
                sel := to_integer(unsigned(sel_vector));
                -- Conversione di sel in ASCII 48 = 0 in ASCII
                MESSAGE(6) <= std_logic_vector(to_unsigned(48 + (sel / 100), 8));   -- Centinaia
                MESSAGE(7) <= std_logic_vector(to_unsigned(48 + ((sel mod 100) / 10), 8)); -- Decine
                MESSAGE(8) <= std_logic_vector(to_unsigned(48 + (sel mod 10), 8));  -- Unità                
            end if;
        end if;
    end process;

    -- Tick ogni 1 secondo
    process(clk)
    begin
        if rising_edge(clk) then
            if one_sec_cnt = ONE_SEC_TICKS - 1 then
                one_sec_cnt <= 0;
                start_transmission <= '1';
            else
                one_sec_cnt <= one_sec_cnt + 1;
                start_transmission <= '0';
            end if;
        end if;
    end process;

    -- Generazione del baud_tick
    process(clk)
    begin
        if rising_edge(clk) then
            if sending = '1' then
                if baud_cnt = BAUD_TICKS - 1 then
                    baud_cnt <= 0;
                    baud_tick <= '1';
                else
                    baud_cnt <= baud_cnt + 1;
                    baud_tick <= '0';
                end if;
            else
                baud_cnt <= 0;
                baud_tick <= '0';
            end if;
        end if;
    end process;

    -- Logica trasmissione UART
    process(clk)
    begin
        if rising_edge(clk) then
            if sending = '0' then
                tx_reg <= '1';  -- Idle
                if start_transmission = '1' then
                    sending <= '1';
                    char_index <= 0;
                    bit_index <= 0;
                    current_byte <= MESSAGE(0);
                end if;

            elsif baud_tick = '1' then
                case bit_index is
                    when 0 =>
                        tx_reg <= '0';  -- Start
                    when 1 to 8 =>
                        tx_reg <= current_byte(bit_index - 1);  -- Data (LSB first)
                    when 9 =>
                        tx_reg <= '1';  -- Stop
                    when others =>
                        tx_reg <= '1';
                end case;

                if bit_index = (9 + DUMMY_BITS) then
                    if char_index = MSG_LENGTH - 1 then
                        sending <= '0';
                    else
                        char_index <= char_index + 1;
                        current_byte <= MESSAGE(char_index + 1);
                        bit_index <= 0;
                    end if;
                else
                    bit_index <= bit_index + 1;
                end if;
            end if;
        end if;
    end process;

    ------------------------------------------------------------
    -- RICEZIONE UART
    ------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if start_bit_detected = '0' then
                if rx = '0' then  -- Bit di start rilevato
                    start_bit_detected <= '1';                    
                    baud_cnt_rx <= 0;
                end if;
            else
                baud_cnt_rx <= baud_cnt_rx + 1;

                if baud_cnt_rx = BAUD_TICKS / 2 then
                    rx_sampled <= rx;  -- Campiona il bit a metà periodo
                end if;

                if baud_cnt_rx = BAUD_TICKS - 1 then
                    baud_cnt_rx <= 0;
                    bit_index_rx <= bit_index_rx + 1;

                    if bit_index_rx >= 1 and bit_index_rx <= 8 then
                        rx_data(bit_index_rx - 1) <= rx_sampled;
                    elsif bit_index_rx = 9 then  -- Bit di stop
                        flag_rx <= not flag_rx;
                        start_bit_detected <= '0';
                        bit_index_rx <= 0;
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;

