-------------------------------------------------------------------------------
-- File : Shift register
-- Autor : Jampag
-- Description: This is an implementation of a 4 bit register
--              behavioral architecture.
--
-- Block Diagram:
--               __________
--     data_in -|          |- A        Every clock
--              |          |           A = data_in
--        clk  -|          |- B        B = A
--              |          |           C = B
--              |          |- C        D = C
--              |          |
--       reset -|__________|- D
--              
-------------------------------------------------------------------------------

-- Library 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entity Declaration
entity Shift_Reg is
port (
	A		: out std_logic;
	B		: out std_logic;
	C		: out std_logic;
	D		: out std_logic;
    data_in : in  std_logic;
	clk     : in  std_logic;
	reset   : in  std_logic);
end Shift_Reg;

-- Architecture
architecture behavior of Shift_Reg is

	-- Defined Signals
	signal A_reg, B_reg, C_reg, D_reg : std_logic := '0';
	-- I registri sono usati per memorizzare lo stato 

-- Begin Architecture
begin

    -- Signal Assignments
    A <= A_reg;
	B <= B_reg;
	C <= C_reg;
	D <= D_reg;
	 
	-- Process 
	reg_process: process(clk)
	begin
		if(rising_edge(clk)) then 
			if(reset = '1') then
                A_reg <= '0';
                B_reg <= '0';
                C_reg <= '0';
                D_reg <= '0';
		    else
			    A_reg <= data_in;
				B_reg <= A_reg;
				C_reg <= B_reg;
				D_reg <= C_reg;
		    end if;
		 end if;
	end process reg_process;
	
end behavior;
