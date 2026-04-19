-------------------------------------------------------------------------------
-- File : clock_div_strobe
-- Author : Jampag
-- Date : 2026 March 08
-- Description: Clock divider by X, used a CE of the BUFGECE
--              __    __    __    __     __     __  
-- i_clk       ^  |  ^  |  ^  |  ^  |   ^  |   ^  | 
--           __|  |__|  |__|  |__|  |___|  |___|  |_
--            __                              __
-- CE        |  |                            |  |
--         __|  |____________________________|  |__ 
--              __                              __
-- o_clk_div   |  |                            |  |
--           __|  |____________________________|  |__ 
--
-- Revision: 1.0 
-- Dependencies: BUFGCE UG953
-- Additional Comments:x

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
-- Primitive Xilinx
library UNISIM;
use UNISIM.VComponents.all;


entity clock_div_strobe is
    generic (
        DIVIDE : integer := 25   -- DIVIDE must be greater than 1
    );
    port ( 
        i_clk     : in  std_logic;  
        reset      : in  std_logic;
        o_clk_div : out std_logic
    );
end clock_div_strobe;

architecture Behavioral of clock_div_strobe is

    signal clk_en   : std_logic := '0';
    signal clk_slow : std_logic;
    constant BIT_DEPTH : integer := integer(ceil(log2(real(DIVIDE))));
    constant MAX_VAL_U : unsigned(BIT_DEPTH-1 downto 0) := to_unsigned(DIVIDE-1, BIT_DEPTH);
    signal count_reg   : unsigned(BIT_DEPTH-1 downto 0) := (others => '0');

begin

    ----------------------------------------------------------------
    -- Counter: gerate a CE 
    ----------------------------------------------------------------
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if reset = '1' then
                count_reg <= (others => '0');
                clk_en  <= '0';

            else
                if count_reg = MAX_VAL_U then
                    count_reg <= (others => '0');
                    clk_en  <= '1';   -- enabel clk for a cicle
                else
                    count_reg <= count_reg + 1;
                    clk_en  <= '0';
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Global Clock Buffer with Clock Enable
    ----------------------------------------------------------------
    BUFGCE_inst : BUFGCE
    port map (
        O  => clk_slow,
        CE => clk_en,
        I  => i_clk
    );

    o_clk_div <= clk_slow;

end Behavioral;
