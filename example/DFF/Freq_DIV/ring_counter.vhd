-------------------------------------------------------------------------------
-- File : ring_counter
-- Author : Jampag
-- Date : 2026-01-11
-- Description: ring-counter with sync reset
--             __    __    __    __    __    __    __    __    __    __   
--      Clk   ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  ^  |  
--          __|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__
--                               _____                      _____
--      bit0                    |     |                    |     |
--          ____________________|     |____________________|     |________
--                                                             ___________
--      reset                                                 |
--          __________________________________________________|
--
--Note :


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ring_counter is
    generic(
        N : integer := 4
    );
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        bit0  : out std_logic
    );
end entity;

architecture rtl of ring_counter is

    signal ring : std_logic_vector(N-1 downto 0) := (0 => '1', others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                ring <= (0 => '1', others => '0');
            else
                ring <= ring(N-2 downto 0) & ring(N-1);
            end if;
        end if;
    end process;

    bit0 <= ring(N-1);

end architecture;
