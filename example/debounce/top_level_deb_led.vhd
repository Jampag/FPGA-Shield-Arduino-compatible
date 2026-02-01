-------------------------------------------------------------------------------
-- File : top_level_deb_led.vhd
-- Autor : Jampag
-- Data : 2026 Jan 27
-- Description: Top-level example, how to implement anti-debounce circuit
--                _______________________________________                
--               |                                       |
--   Clk(100MHz)-|--.-------------------.                |
--               |  |  ___________      |  ___________   | 
--               |  '-|i_clk      |     '-| clk       |  |         
--   [SW1]_ \__ -|----|i_bounce   |       |           |  |   ↑↑          
--               |    | o_debounce|-------| SW1     L1|--|- -►|—  [L1]
--               |    |___________|       |___________|  |
--               |  'Debounce_btn.vhd'  'LED_toggle.vhd' |
--               |_______________________________________|  
--
--                
-- Dependencies: Debounce_btn.vhd; LED_toggle.vhd
-- Revision: 1.0 top_level_deb_led.vhd
-- Additional Comments:x

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Entity 
entity top_level_deb_led is
    Port (
        L1    : out std_logic;
        clk   : in std_logic;
        SW1   : in std_logic
        );
end top_level_deb_led; 

-- Architecture
architecture behavior of top_level_deb_led is
    
    -------------------------
    -- Component declaration
    -------------------------
    component Debounce_btn
        generic(
            DEBOUNCE_cnt    : integer ;
            INIT_state      : std_logic
        );
        Port (
            i_clk    : in std_logic;
            i_bounce : in std_logic;
            o_debounce : out std_logic
        );
    end component;
    
    component LED_toggle
        Port (
            L1    : out std_logic;
            clk   : in std_logic;
            SW1   : in std_logic
        );
    end component;    
    
    --------------------
    -- Internal signals
    --------------------
    signal btn_debounced    : std_logic;

 begin
 
    -----------------------
    -- Debounce instance
    -----------------------
    u_debounce: Debounce_btn
        generic map(
            DEBOUNCE_cnt    => 100_000,
            INIT_state      => '1'
        )
        port map(
            i_clk      => clk,
            i_bounce   => SW1,
            o_debounce => btn_debounced
        );
    -----------------------
    -- LED toggle instance
    -----------------------
    u_toggle: LED_toggle
        port map(
            L1  => L1,
            clk => clk,
            SW1 => btn_debounced
        );

end behavior;

