-------------------------------------------------------------------------------
-- File     : Bin_To_BCD_DD.vhd
-- Author   : Jampag
-- Date     : 2026 October 21
-- Revision : 1.0 
-- Description: Binary to BCD converter based on the Double Dabble
--              (Shift-Add-3) algorithm.
--              The conversion is performed sequentially and requires
--              G_BIN_WIDTH clock cycles to complete.
--
--              Procedure:
--              1) For each BCD digit, add 3 if digit >= 5.
--              2) Shift the complete BCD register left by one bit.
--              3) Insert the current MSB of the binary register into
--                 the BCD register(C, D, U container).
--              4) Repeat until all binary bits have been processed.
-- 
-- Block Diagram:
--
--                _______________________________
--               |                               |
--     i_Bin --->|     Double Dabble Engine      |---> o_BCD
--               |                               |
--   i_Start --->|  FSM + Add-3 + Shift Logic    |
--               |                               |
--     i_Clk --->|                               |
--               |_______________________________|---> o_Ready
--
--  Example:
--     Double Dabble Example (0xF7 -> 247)
--      Binary Input : 1111_0111 (0xF7)
--      Decimal      : 247
--      BCD Output   : 0010_0100_0111
--      G_BIN_WIDTH  : 8
--      G_BCD_DIGITS : 3
--    
--     +---------+----------------------------------+------+------+------+------------+
--     | Cycle   | State / Action                   |  C   |  D   |  U   |   r_Bin    |
--     +---------+----------------------------------+------+------+------+------------+
--     | START   | Load Input                       | 0000 | 0000 | 0000 | 11110111   |
--     |    1    | Check (none >=5) -> Shift        | 0000 | 0000 | 0001 | 1110111.   |
--     |    2    | Check (none >=5) -> Shift        | 0000 | 0000 | 0011 | 110111..   |
--     |    3    | Check (none >=5) -> Shift        | 0000 | 0000 | 0111 | 10111...   |
--     |    4    | Check (U=7, Add 3) -> Shift      | 0000 | 0001 | 0101 | 0111....   |
--     |    5    | Check (U=5, Add 3) -> Shift      | 0000 | 0011 | 0000 | 111.....   |
--     |    6    | Check (none >=5) -> Shift        | 0000 | 0110 | 0001 | 11......   |
--     |    7    | Check (D=6, Add 3) -> Shift      | 0001 | 0010 | 0011 | 1.......   |
--     |    8    | Check (none >=5) -> Shift        | 0010 | 0100 | 0111 | ........   |
--     | DONE    | Conversion Complete              | 0010 | 0100 | 0111 | ........   |
--     +---------+----------------------------------+------+------+------+------------+
-- Timing Example: x
--
-- Dependencies: x
-- Note: G_BCD_DIGITS must be large enough to represent the maximum decimal 
--       value corresponding to G_BIN_WIDTH.
--       Use this formula: G_BCD_DIGITS = ceil(G_BIN_WIDTH * log10(2))
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bin_To_BCD_DD is
    generic (
        G_BIN_WIDTH  : integer := 32;
        -- Must be use this : G_BCD_DIGITS = ceil( G_BIN_WIDTH * log10(2) ) 
        G_BCD_DIGITS : integer := 10
    );
    port (
        i_Clk   : in std_logic;
        i_Reset : in std_logic;
        i_Bin   : in std_logic_vector(G_BIN_WIDTH - 1 downto 0);
        i_Start : in std_logic;
        o_Ready : out std_logic;
        o_BCD   : out std_logic_vector((G_BCD_DIGITS*4) - 1 downto 0)
    );
end Bin_To_BCD_DD;    

architecture Behavioral of  Bin_To_BCD_DD is

    -- FSM
    type t_State is (IDLE, CONVERTING, DONE);
    signal r_State : t_State := IDLE;
    
    -- Counter
    signal r_shift_cnt : integer range 0 to G_BIN_WIDTH - 1 := 0;
    
    -- Data
    signal r_Bin   : unsigned(G_BIN_WIDTH-1 downto 0) := (others => '0');
    signal r_BCD   : unsigned((G_BCD_DIGITS*4)-1 downto 0) := (others => '0');
    signal r_Ready : std_logic := '0';
    
    

begin

    o_Ready <= r_Ready;
    o_BCD   <= std_logic_vector(r_BCD);

    process(i_Clk)
        -- Variables used to compute the +3 addition in the same clock cycle
        variable v_BCD   : unsigned((G_BCD_DIGITS*4) - 1 downto 0);
        variable v_H_idx : integer;
        variable v_L_idx : integer;
    begin 
        if rising_edge(i_Clk) then
            if i_Reset = '0' then
                r_State     <= IDLE;
                r_shift_cnt <= 0;
                r_BCD       <= (others =>  '0');                
              
            else
            
                case r_State is
                    when IDLE => 
                        if i_Start = '1' then
                            r_State     <= CONVERTING;
                            r_Bin       <= unsigned(i_Bin);
                            r_BCD       <= (others =>  '0'); 
                            r_Ready     <= '0';
                            r_shift_cnt <= 0;
                        end if;
                    
                    when CONVERTING => 
                        
                        v_BCD := r_BCD;
                        
                        -- Add +3 if nibble >=5
                        for i in 0 to G_BCD_DIGITS - 1 loop
                            v_H_idx := (i*4) + 3; -- nibble high index
                            v_L_idx := i*4; -- nibble low index
                            if ( v_BCD( v_H_idx downto v_L_idx ) >= 5 ) then
                                v_BCD( v_H_idx downto v_L_idx ) := v_BCD( v_H_idx downto v_L_idx ) + 3;                               
                            end if;                        
                        end loop;
                        
                        -- Shift left v_BCD and move MSB from r_BIN
                        r_BCD <= v_BCD((G_BCD_DIGITS*4)-2 downto 0) & r_Bin(G_BIN_WIDTH-1);
                        
                        -- Add '0' at LSB of r_Bin
                        r_Bin <= r_Bin(G_BIN_WIDTH-2 downto 0) & '0';
                        
                        -- Counter 
                        if (r_shift_cnt = G_BIN_WIDTH - 1 )then
                            r_State <= DONE;
                        else 
                            r_shift_cnt <= r_shift_cnt + 1;
                        end if;

                    when DONE => 
                        r_State <= IDLE;
                        r_Ready <= '1';
                    
                end case;
            
            end if;
            
        end if;
    end process ;


end Behavioral;
