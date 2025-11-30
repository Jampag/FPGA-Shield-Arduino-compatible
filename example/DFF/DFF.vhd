-------------------------------------------------------------------------------
-- File : DFF.vhd
-- Autor : Jampag
-- Description: D Flip Flop with Clock Enable and Sync Reset
--            ______
-- Data  ----|      |---- Q
--           | DFF  |     
--  Clk  ----|      |
--           |      |
--   CE  ----|______|
--    R  _______|
--
--  Inputs            Outputs
-- |Reset|CE|Data|Clk|Q
-- |1    |X |X   |^  |0
-- |0    |0 |X   |X  |No Change
-- |0    |1 |D   |^  |D
--
--NOTE:
--std_ulogic(unresolved type):
-- e due processi tentano di pilotare contemporaneamente un segnale di tipo 
-- std_ulogic, il compilatore genera un errore.
-- Quando sei sicuro che il segnale sia pilotato da un solo driver.
-- Quando vuoi proteggere il design da errori causati da driver multipli.
-- Per migliorare l'efficienza nei tool di sintesi.
-------------------------------------------------------------------------------

-- Library 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entity Declaration
entity DFlipFlop is
    port (
        Data	: in std_ulogic;
        Clk		: in std_ulogic;
		CE      : in std_ulogic; -- Clock Enable
        Reset	: in std_ulogic; -- Reset
        Q		: out std_ulogic);
end DFlipFlop;

-- Architecture
architecture behavior of DFlipFlop is

-- Defined Signals
    signal Q_reg : std_ulogic;

-- Begin Architecture
begin
    
    Q <= Q_reg;
	process(Clk)
	begin
		if (rising_edge(Clk)) then
            if Reset = '1' then
                Q_reg <= '0';
            elsif (CE = '1') then
                Q_reg <= Data;
            end if;
		end if;
	end process;
	
end behavior;

