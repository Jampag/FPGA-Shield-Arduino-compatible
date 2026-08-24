-------------------------------------------------------------------------------
-- File     : vending_machine_fsm.vhd
-- Author   : Jampag
-- Date     : 2026 august 20
-- Revision : 1.0 
-- Description:
--   Example of an FSM for a vendig machine 
-- Block Diagram:
--
--                              Coin                  Coin
--                    .---------------------.   .------------------.
--                    |                     |   |                  |
--                    |                     v   |                  v
--  RESET/    .-------+-------.       .-----+---+-----.    .-------+-------.
--  START     |               |       |               |    |               |
--    o------>| LOCKED_0_COIN |--. .--| LOCKED_1_COIN |    |   UNLOCKED    |
--            |               |  | |  |               |    |               |
--            '-------+-------'<-' '->'---------------'    '-------+-------'
--                    ^   No Coin      No Coin                     |
--                    |                                            |
--                    |                     Dispense               |
--                    '--------------------------------------------'
--
-- Dependencies: x
-- Note: x

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vending_machine_fsm is
    port (
        i_reset     : in std_logic;
        i_coin      : in std_logic;
        i_clk       : in std_logic;
        o_dispense  : out std_logic
    );
end entity vending_machine_fsm;

architecture RTL of vending_machine_fsm is

    type t_State is (LOCKED_0_COIN, LOCKED_1_COIN, DISPENSE);
    signal r_Curr_State : t_State;

begin

    process(i_clk, i_reset )
    begin
        if (i_reset = '1') then
            r_Curr_State <= LOCKED_0_COIN;
        
        elsif rising_edge(i_clk) then

            case r_Curr_State is
                when LOCKED_0_COIN =>
                    if i_coin = '1' then
                        r_Curr_State <= LOCKED_1_COIN;
                    end if;
                when LOCKED_1_COIN =>
                    if i_coin = '1' then
                        r_Curr_State <= DISPENSE;
                    end if;
                when DISPENSE =>
                    r_Curr_State <= LOCKED_0_COIN;
            end case;

        end if;
    end process;
    
    o_dispense <= '1' when r_Curr_State = DISPENSE else '0';

end architecture RTL;
