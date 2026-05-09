-------------------------------------------------------------------------------
-- File     : top_uart_status.vhd
-- Author   : Jampag
-- Date     : 2026 may 03
-- Revision : 1.0
-- Description:
--   Top-level example for connecting uart_rx_status.vhd and
--   uart_tx_status.vhd 
-- Block Diagram:
--            _____________________________________________________                  
--           |                                                     |      
--   i_Clk --|--+--------------------------.                       |      
--           |  |  ________________        |  _________________    | 
--           |  | |                |       | |                 |   |
--           |  '-|i_Clk           |       '-|i_Clk        o_TX|-->|-- o_TX
--   i_RX ---|----|i_Rx            |         |                 |   |
--           |    |     o_Buf_Ready|---------|i_DV             |   |
--           |    |     o_Data[7:0]|---+-+---|i_Data[15:0]     |   |
--           |    |________________|   | |   |_________________|   |
--           |   'uart_rx_status.vhd'  | |   'uart_tx_status.vhd'  |
--           |                         | '------------------------<|-- i_Data[7:0]
--           |                         '-------------------------->|-- o_Data[7:0]
--           |_____________________________________________________|  
--                                    
--                
-- Dependencies:
--  uart_rx_status.vhd; uart_tx_status.vhd (Rev 2.0)
-- Additional Comments:x
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity 
entity top_uart_status is
    generic(
        DATA_IN  : integer := 1;
        DATA_OUT : integer := 1
    );
    port (
        i_Clk  : in  std_logic;
        i_RX   : in  std_logic; -- UART Rx     
        o_TX   : out std_logic; -- UART Tx
        i_Data : in  std_logic_vector((DATA_IN * 8) - 1 downto 0);
        o_Data : out std_logic_vector((DATA_OUT * 8) - 1 downto 0);
        i_DV   : in  std_logic  -- Trigger Tx
    );
end top_uart_status; 

architecture Behavioral of top_uart_status is


    -- Component declaration
    component uart_tx_status is
        generic (
            G_CLOCK_FREQ : integer := 100_000_000;
            G_BAUD_RATE  : integer := 115_200;
            G_DATA_BYTES : integer := DATA_OUT + DATA_IN;
            G_DUMMY_BITS : integer := 2;
            G_TRIGGER    : boolean := true
        );    
        port (
            i_Clk  : in  std_logic;
            i_Data : in  std_logic_vector((G_DATA_BYTES * 8) - 1 downto 0 );  -- Input pin state
            o_TX   : out std_logic;
            i_DV   : in  std_logic  
        );        
    end component;
    
    component uart_rx_status is
        generic(
            G_CLOCK_FREQ : integer := 100_000_000;
            G_BAUD_RATE  : integer := 115_200;
            G_DATA_BYTES : integer := DATA_OUT
        ); 
        Port (
            i_Clk       : in  std_logic; 
            i_RX        : in  std_logic; 
            o_Data      : out std_logic_vector((G_DATA_BYTES * 8) - 1 downto 0);
            o_Buf_Ready : out std_logic
        );      
    end component;


    -- Internal signals
    signal w_DV : std_logic := '0';
    signal w_i_Data_tx : std_logic_vector(((DATA_OUT + DATA_IN) * 8) - 1 downto 0) := (others => '0');
    signal w_o_Data_rx : std_logic_vector((DATA_OUT * 8)- 1 downto 0) := (others => '0');


begin

    -- UART Tx istance
    U_uart_tx_status : uart_tx_status
        generic map (
            G_CLOCK_FREQ => 100_000_000,
            G_BAUD_RATE  => 115_200,
            G_DATA_BYTES => DATA_OUT + DATA_IN,
            G_DUMMY_BITS => 2,
            G_TRIGGER    => true
        )  
        port map(
        -- comp port => top-level signal
            i_Clk  => i_Clk,
            i_Data => w_i_Data_tx,
            o_TX   => o_TX,
            i_DV   => w_DV
        ); 

    -- UART Rx istance
    U_uart_rx_status : uart_rx_status
        generic map (
            G_CLOCK_FREQ => 100_000_000,
            G_BAUD_RATE  => 115_200,
            G_DATA_BYTES => 1
        ) 
        port map(
            i_Clk       => i_Clk,
            i_RX        => i_RX,
            o_Data      => w_o_Data_rx,
            o_Buf_Ready => w_DV
        );        
    
    --Assignmets
    w_i_Data_Tx( 15 downto 8 ) <= i_Data;
    w_i_Data_Tx( 7 downto 0 ) <= w_o_Data_rx;
    o_Data <= w_o_Data_rx;
    
    
end architecture Behavioral;
