----------------------------------------------------------------------------------
-- Autor: Jampag
-- 
-- Create Date: 25.04.2025 18:14:31
-- Design Name: Macro UART RX and TX
-- Module Name: test_tot - Behavioral
-- Project Name: Test MODULO FPGA Arduino
-- Target Devices: MODULO FPGA Ver3
-- Tool Versions: 2024.2
-- Description:  Serve per testare il MODULO FPGA Ver 3 il test si divide in:
--      1-Lambeggia L2 ongi 15Hz,se premutp il btn smettere di lampeggiare.
--      2-Solo una volta o al reset tramite btn  imposta tutti i pins in input
--       pull-up e verifica che siano tutti HIGH altrmienti invia la segnalazione
--       su 'sel_out' del pin non HIGH e spegne il led.
--      3-Superato il test 2 verifica ciclicamente pin per pin.
--          -Imposta il pin come uscita LOW e verifica che tutti gli altri a HIGH
--          -Al rilascio del uscita LOW campiona dopo 2clk che il pin sia LOW.
-- 
-- Dependencies: uart_module.vhd; pin-out.xdc;Desing test_wrapper.v
-- Revision: 0.01 test_tot.vhd;Version 1 pin-out.xdc
-- Revision 2.00 - File Created
-- Additional Comments:x
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library UNISIM;
use UNISIM.VComponents.all;


entity test_tot is
    Generic (
        CLK_RATE : integer := 100000000 ;
        nPINS    : integer := 64  -- Numero di pin da testare 65 Ver 3 meno RX e TX uart
    );
    Port (
        led     : out std_logic ;
        led1    : out std_logic ;
        btn     : in  std_logic;
        pins_out    : inout std_logic_vector(nPINS-1 downto 0);
        clk     : in  std_logic;
        sel_out : out std_logic_vector(7 downto 0):= (others => '1') -- Invia sel value in vector     
    );
end test_tot;

architecture Behavioral of test_tot is
    
    constant no_error : std_logic_vector(7 downto 0) := (others => '1');
    
    -- Segnali per IOBUF primitive
    signal pins_out_i : std_logic_vector(nPINS-1 downto 0); -- input dalla porta fisica
    signal pins_out_o : std_logic_vector(nPINS-1 downto 0); -- output verso la porta fisica
    signal pins_out_t : std_logic_vector(nPINS-1 downto 0); -- tri-state control
    
    signal status       : std_logic := '1';
    signal led_status   : std_logic := '0';
    constant BIT_DEPTH  : integer := 28;
    constant MAX_VAL    : integer := CLK_RATE / 30;
    signal count_reg    : unsigned(BIT_DEPTH - 1 downto 0) := (others => '0');

    signal tick         : std_logic := '0';
    signal sel          : integer range 0 to nPINS-1 := 0;
    signal sel_old      : integer range 0 to nPINS-1 := 0;
    signal error        : std_logic := '1';

    --Delay campionamento 1= clk cycle
    constant DELAY_CYCLES_all : integer := 150; --1,5us
    constant DELAY_CYCLES : integer := 2;
    signal delay_count  : integer range 0 to DELAY_CYCLES_all := 0;
    signal delay_flag   : std_logic := '0';
    
    --Verifica che tutti i pin siano HIGH
    signal flag_allHigh : std_logic := '1';
    signal flag_stop : std_logic := '1';
       

    
    
    
begin

    ---------------------------------------------
    -- Istanziazione delle primitive IOBUF
    ---------------------------------------------
    gen_iobuf: for i in 0 to nPINS-1 generate
        IOBUF_inst : IOBUF
        port map (
            O  => pins_out_i(i),
            IO => pins_out(i),
            I  => pins_out_o(i),
            T  => pins_out_t(i)
        );
    end generate;

    ---------------------------------------------
    -- LED blink e test pulsante
    ---------------------------------------------
    led1 <= led_status and btn;

    count_proc: process(clk)
    begin 
        if rising_edge(clk) then
            if (count_reg = MAX_VAL) then
                count_reg <= (others => '0');
                tick <= '1';
                --led_status <= not led_status;
            else 
                count_reg <= count_reg + 1;
                tick <= '0';
            end if;
        end if;
    end process; 

    ---------------------------------------------
    -- Assegnazione dei pin (drive solo il selezionato)
    ---------------------------------------------
    gen_pins: for i in 0 to nPINS-1 generate
        pins_out_o(i) <= '0';
        pins_out_t(i) <= '0' when (flag_allHigh = '0' and sel = i) else '1'; -- '0' => drive, '1' => alta impedenza
    end generate;


    ---------------------------------------------
    -- Processo di test con ritardo
    ---------------------------------------------
process(clk)
begin
    if rising_edge(clk) then
        status <= '1';
        
        if btn = '0' then
            error <= '1';
            sel_out <= no_error;
            flag_allHigh <= '1';
             delay_count <= 0;
        -- Verifica iniziale se tutti i pin sono HIGH
        elsif flag_allHigh = '1' then
            if delay_count < DELAY_CYCLES_all then
                delay_count <= delay_count + 1;
            else
                delay_count <= 0;
                
                -- Qui controlliamo TUTTI i pin siano HIGH
                for i in 0 to nPINS-1 loop
                    if pins_out_i(i) /= '1' then
                        error <= '0';
                        sel_out <= std_logic_vector(to_unsigned(i, 8));                       
                    end if;
                end loop;

                -- Fine fase iniziale
                flag_allHigh <= '0';
                flag_stop <= '1';
            end if;
         end if;

        -- Verica corti tra pin e pin e pin e VCC
        if delay_flag = '1' and flag_stop = '1' then
            if delay_count < DELAY_CYCLES then
                delay_count <= delay_count + 1;
            else
                delay_count <= 0;
                delay_flag <= '0';
                -- Campionamento dopo rilascio (2 clock, dopo 20ns)
                led_status <= not led_status; -- Capture Trigger and led blink 
                -- Verifica che il pin appena rilasciato IN sia 0
                if pins_out_i(sel_old) /= '0' and error /= '0' then
                    error <= '0';
                    sel_out <= std_logic_vector(to_unsigned(sel_old, 8));
                end if;
            end if;

        elsif tick = '1' and flag_stop = '1'  then
            -- Controllo che gli altri pin siano HIGH
            for i in 0 to nPINS-1 loop
                if i /= sel then
                    if pins_out_i(i) /= '1' and error /= '0' then
                        error <= '0';
                        sel_out <= std_logic_vector(to_unsigned(sel, 8));                       
                    end if;
                end if;
            end loop;            

            -- Salva il pin selezionato prima di passare al prossimo
            sel_old <= sel;

            -- Passa al prossimo pin
            if sel = nPINS - 1 then
                sel <= 0;
            else
                sel <= sel + 1;
            end if;

            -- Avvia il ritardo
            delay_flag <= '1';
        end if;
    end if;
end process;

    ---------------------------------------------
    -- LED di stato
    ---------------------------------------------
    led <= status and error; -- Led OFF = error



end Behavioral;
