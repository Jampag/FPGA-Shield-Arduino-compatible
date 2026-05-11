-------------------------------------------------------------------------------
-- File     : alarm_reg.vhd
-- Author   : Jampag
-- Date     : 2026 may 10
-- Revision : 1.0
-- Description:
--   Alarm register used to store the first input variation after reset.
--
--   During reset, r_data is loaded with the current i_data value and used as
--   the initial reference. After reset, i_data is compared with r_data.
--
--   At the first detected variation, the new i_data value is saved into r_data
--   and r_alarm is set. From this moment, o_data remains locked and further
--   input changes are ignored until the next reset.
--
--
--   Useful for storing short events, pin variations, status changes or alarm
--   inputs until the system clears the event by reset.
--
-- Block Diagram:
--             _____
--            |     |
--   i_Clk  ->|    >|- o_data
--            |     |
--   i_rst  ->|     |
--            |     |
--   i_data ->|     |
--            |_____|
--
-- Timing Example:
--
--   i_Clk         |__|__|__|__|__|__|__|__|__|__|__|
--
--   i_rst          0  0  1  1  1  1  1  1  0  1  1
--   i_data         0  0  0  0  1  0  1  1  1  1  0
--   r_data         0  0  0  0  1  1  1  1  1  1  0
--   r_alarm        0  0  0  0  1  1  1  1  0  0  1
--   o_data         0  0  0  0  1  1  1  1  1  1  0
--   event                     ^                 ^
--
-- Note: x
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alarm_reg is
    port(
        i_Clk   : in  std_logic;
        i_rst   : in  std_logic;
        i_data  : in  std_logic;
        o_data  : out std_logic
    );
end entity alarm_reg;

architecture Behavioral of alarm_reg is

    signal r_data  : std_logic := '0';
    signal r_alarm : std_logic := '0';

begin

    o_data <= r_data;

    process(i_Clk)
    begin
        if rising_edge(i_Clk) then

            if i_rst = '0' then

                r_data  <= i_data ;
                r_alarm <= '0';

            else

                if i_data /= r_data and r_alarm = '0' then
                    r_data  <= i_data;
                    r_alarm <= '1';
                end if;

            end if;

        end if;
    end process;

end architecture Behavioral;
