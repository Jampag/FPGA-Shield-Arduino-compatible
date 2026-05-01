-------------------------------------------------------------------------------
-- File     : LFSR_Generic.vhd
-- Author   : Jampag
-- Date     : 2026 april 30
-- Revision : 1.0 
-- Description:
--   LFSR xx-Bit with XNOR gate port, chose a Nbit from 3 to 40
-- Block Diagram:
--

--             __________________ 
--  i_Clk-----|>   LFSR_generic  |
--            |                  | 
--            |            o_Data|-------> o_Data
--            |                  |
--            |         o_LFSR(0)|--
--            |         o_LFSR(1)|--
--            |         o_LFSR(X)|--
-- i_Rese-----|R                 |
--            |__________________|
--     
-- Dependencies: x
-- Note: 
--  Referance XAPP052.PDF  
--
--  If o_LFSR(x) is not needed, instantiate LFSR_Generic
--   in a top-level entity that exposes only the serial output.
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LFSR_Generic is
    generic (
        NUM_BITS : integer range 3 to 40 := 5 -- Default bit width
    );
    port (
        i_Clk   : in  std_logic;
        i_Reset : in  std_logic; 
        o_Data  : out std_logic;
        o_LFSR  : out std_logic_vector(NUM_BITS-1 downto 0)        
    );
end entity LFSR_Generic;

architecture RTL of LFSR_Generic is

    signal r_LFSR : std_logic_vector(NUM_BITS-1 downto 0) := (others => '0');
    signal w_XNOR : std_logic;

begin

    -----------------------------------------------------------
    -- LFSR Shift Process
    -----------------------------------------------------------
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Reset = '0' then
                r_LFSR <= (others => '0');
            else
                -- Shift Left operation:
                -- The bits are shifted towards the MSB, and the feedback (w_XNOR)
                -- is inserted into the LSB (index 0).
                r_LFSR <= r_LFSR(NUM_BITS-2 downto 0) & w_XNOR;
            end if;
        end if;
    end process;
    

    -----------------------------------------------------------
    -- Feedback Logic (Taps Selection)
    -- Polynomials based on XAPP052 (indices shifted by -1)
    -----------------------------------------------------------
    
    -- Case 3 Bit: Taps (3,2) -> Indices (2,1)
    g_LFSR_3 : if NUM_BITS = 3 generate
        w_XNOR <= r_LFSR(2) xnor r_LFSR(1);
    end generate g_LFSR_3;

    -- Case 4 Bit: Taps (4,3) -> Indices (3,2)
    g_LFSR_4 : if NUM_BITS = 4 generate
        w_XNOR <= r_LFSR(3) xnor r_LFSR(2);
    end generate g_LFSR_4;

    -- Case 5 Bit: Taps (5,3) -> Indices (4,2)
    g_LFSR_5 : if NUM_BITS = 5 generate
        w_XNOR <= r_LFSR(4) xnor r_LFSR(2);
    end generate g_LFSR_5;

    -- Case 6 Bit: Taps (6,5) -> Indices (5,4)
    g_LFSR_6 : if NUM_BITS = 6 generate
        w_XNOR <= r_LFSR(5) xnor r_LFSR(4);
    end generate g_LFSR_6;

    -- Case 7 Bit: Taps (7,6) -> Indices (6,5)
    g_LFSR_7 : if NUM_BITS = 7 generate
        w_XNOR <= r_LFSR(6) xnor r_LFSR(5);
    end generate g_LFSR_7;

    -- Case 8 Bit: Taps (8,6,5,4) -> Indices (7,5,4,3)
    g_LFSR_8 : if NUM_BITS = 8 generate
        w_XNOR <= r_LFSR(7) xnor r_LFSR(5) xnor r_LFSR(4) xnor r_LFSR(3);
    end generate g_LFSR_8;

    -- Case 9 Bit: Taps (9,5) -> Indices (8,4)
    g_LFSR_9 : if NUM_BITS = 9 generate
        w_XNOR <= r_LFSR(8) xnor r_LFSR(4);
    end generate g_LFSR_9;

    -- Case 10 Bit: Taps (10,7) -> Indices (9,6)
    g_LFSR_10 : if NUM_BITS = 10 generate
        w_XNOR <= r_LFSR(9) xnor r_LFSR(6);
    end generate g_LFSR_10;

    -- Case 11 Bit: Taps (11,9) -> Indices (10,8)
    g_LFSR_11 : if NUM_BITS = 11 generate
        w_XNOR <= r_LFSR(10) xnor r_LFSR(8);
    end generate g_LFSR_11;

    -- Case 12 Bit: Taps (12,6,4,1) -> Indices (11,5,3,0)
    g_LFSR_12 : if NUM_BITS = 12 generate
        w_XNOR <= r_LFSR(11) xnor r_LFSR(5) xnor r_LFSR(3) xnor r_LFSR(0);
    end generate g_LFSR_12;

    -- Case 13 Bit: Taps (13,4,3,1) -> Indices (12,3,2,0)
    g_LFSR_13 : if NUM_BITS = 13 generate
        w_XNOR <= r_LFSR(12) xnor r_LFSR(3) xnor r_LFSR(2) xnor r_LFSR(0);
    end generate g_LFSR_13;

    -- Case 14 Bit: Taps (14,5,3,1) -> Indices (13,4,2,0)
    g_LFSR_14 : if NUM_BITS = 14 generate
        w_XNOR <= r_LFSR(13) xnor r_LFSR(4) xnor r_LFSR(2) xnor r_LFSR(0);
    end generate g_LFSR_14;

    -- Case 15 Bit: Taps (15,14) -> Indices (14,13)
    g_LFSR_15 : if NUM_BITS = 15 generate
        w_XNOR <= r_LFSR(14) xnor r_LFSR(13);
    end generate g_LFSR_15;

    -- Case 16 Bit: Taps (16,15,13,4) -> Indices (15,14,12,3)
    g_LFSR_16 : if NUM_BITS = 16 generate
        w_XNOR <= r_LFSR(15) xnor r_LFSR(14) xnor r_LFSR(12) xnor r_LFSR(3);
    end generate g_LFSR_16;

    -- Case 17 Bit: Taps (17,14) -> Indices (16,13)
    g_LFSR_17 : if NUM_BITS = 17 generate
        w_XNOR <= r_LFSR(16) xnor r_LFSR(13);
    end generate g_LFSR_17;

    -- Case 18 Bit: Taps (18,11) -> Indices (17,10)
    g_LFSR_18 : if NUM_BITS = 18 generate
        w_XNOR <= r_LFSR(17) xnor r_LFSR(10);
    end generate g_LFSR_18;

    -- Case 19 Bit: Taps (19,6,2,1) -> Indices (18,5,1,0)
    g_LFSR_19 : if NUM_BITS = 19 generate
        w_XNOR <= r_LFSR(18) xnor r_LFSR(5) xnor r_LFSR(1) xnor r_LFSR(0);
    end generate g_LFSR_19;

    -- Case 20 Bit: Taps (20,17) -> Indices (19,16)
    g_LFSR_20 : if NUM_BITS = 20 generate
        w_XNOR <= r_LFSR(19) xnor r_LFSR(16);
    end generate g_LFSR_20;

    -- Case 21 Bit: Taps (21,19) -> Indices (20,18)
    g_LFSR_21 : if NUM_BITS = 21 generate
        w_XNOR <= r_LFSR(20) xnor r_LFSR(18);
    end generate g_LFSR_21;

    -- Case 22 Bit: Taps (22,21) -> Indices (21,20)
    g_LFSR_22 : if NUM_BITS = 22 generate
        w_XNOR <= r_LFSR(21) xnor r_LFSR(20);
    end generate g_LFSR_22;

    -- Case 23 Bit: Taps (23,18) -> Indices (22,17)
    g_LFSR_23 : if NUM_BITS = 23 generate
        w_XNOR <= r_LFSR(22) xnor r_LFSR(17);
    end generate g_LFSR_23;

    -- Case 24 Bit: Taps (24,23,22,17) -> Indices (23,22,21,16)
    g_LFSR_24 : if NUM_BITS = 24 generate
        w_XNOR <= r_LFSR(23) xnor r_LFSR(22) xnor r_LFSR(21) xnor r_LFSR(16);
    end generate g_LFSR_24;

    -- Case 25 Bit: Taps (25,22) -> Indices (24,21)
    g_LFSR_25 : if NUM_BITS = 25 generate
        w_XNOR <= r_LFSR(24) xnor r_LFSR(21);
    end generate g_LFSR_25;

    -- Case 26 Bit: Taps (26,6,2,1) -> Indices (25,5,1,0)
    g_LFSR_26 : if NUM_BITS = 26 generate
        w_XNOR <= r_LFSR(25) xnor r_LFSR(5) xnor r_LFSR(1) xnor r_LFSR(0);
    end generate g_LFSR_26;

    -- Case 27 Bit: Taps (27,5,2,1) -> Indices (26,4,1,0)
    g_LFSR_27 : if NUM_BITS = 27 generate
        w_XNOR <= r_LFSR(26) xnor r_LFSR(4) xnor r_LFSR(1) xnor r_LFSR(0);
    end generate g_LFSR_27;

    -- Case 28 Bit: Taps (28,25) -> Indices (27,24)
    g_LFSR_28 : if NUM_BITS = 28 generate
        w_XNOR <= r_LFSR(27) xnor r_LFSR(24);
    end generate g_LFSR_28;

    -- Case 29 Bit: Taps (29,27) -> Indices (28,26)
    g_LFSR_29 : if NUM_BITS = 29 generate
        w_XNOR <= r_LFSR(28) xnor r_LFSR(26);
    end generate g_LFSR_29;

    -- Case 30 Bit: Taps (30,6,4,1) -> Indices (29,5,3,0)
    g_LFSR_30 : if NUM_BITS = 30 generate
        w_XNOR <= r_LFSR(29) xnor r_LFSR(5) xnor r_LFSR(3) xnor r_LFSR(0);
    end generate g_LFSR_30;

    -- Case 31 Bit: Taps (31,28) -> Indices (30,27)
    g_LFSR_31 : if NUM_BITS = 31 generate
        w_XNOR <= r_LFSR(30) xnor r_LFSR(27);
    end generate g_LFSR_31;

    -- Case 32 Bit: Taps (32,22,2,1) -> Indices (31,21,1,0)
    g_LFSR_32 : if NUM_BITS = 32 generate
        w_XNOR <= r_LFSR(31) xnor r_LFSR(21) xnor r_LFSR(1) xnor r_LFSR(0);
    end generate g_LFSR_32;

    -- Case 33 Bit: Taps (33,20) -> Indices (32,19)
    g_LFSR_33 : if NUM_BITS = 33 generate
        w_XNOR <= r_LFSR(32) xnor r_LFSR(19);
    end generate g_LFSR_33;

    -- Case 34 Bit: Taps (34,27,2,1) -> Indices (33,26,1,0)
    g_LFSR_34 : if NUM_BITS = 34 generate
        w_XNOR <= r_LFSR(33) xnor r_LFSR(26) xnor r_LFSR(1) xnor r_LFSR(0);
    end generate g_LFSR_34;

    -- Case 35 Bit: Taps (35,33) -> Indices (34,32)
    g_LFSR_35 : if NUM_BITS = 35 generate
        w_XNOR <= r_LFSR(34) xnor r_LFSR(32);
    end generate g_LFSR_35;

    -- Case 36 Bit: Taps (36,25) -> Indices (35,24)
    g_LFSR_36 : if NUM_BITS = 36 generate
        w_XNOR <= r_LFSR(35) xnor r_LFSR(24);
    end generate g_LFSR_36;

    -- Case 37 Bit: Taps (37,5,2,1) -> Indices (36,4,1,0)
    g_LFSR_37 : if NUM_BITS = 37 generate
        w_XNOR <= r_LFSR(36) xnor r_LFSR(4) xnor r_LFSR(1) xnor r_LFSR(0);
    end generate g_LFSR_37;

    -- Case 38 Bit: Taps (38,6,1) -> Indices (37,5,0)
    g_LFSR_38 : if NUM_BITS = 38 generate
        w_XNOR <= r_LFSR(37) xnor r_LFSR(5) xnor r_LFSR(0);
    end generate g_LFSR_38;

    -- Case 39 Bit: Taps (39,35) -> Indices (38,34)
    g_LFSR_39 : if NUM_BITS = 39 generate
        w_XNOR <= r_LFSR(38) xnor r_LFSR(34);
    end generate g_LFSR_39;

    -- Case 40 Bit: Taps (40,38,21,19) -> Indices (39,37,20,18)
    g_LFSR_40 : if NUM_BITS = 40 generate
        w_XNOR <= r_LFSR(39) xnor r_LFSR(37) xnor r_LFSR(20) xnor r_LFSR(18);
    end generate g_LFSR_40;
    
    -----------------------------------------------------------
    -- OUTPUT 
    -----------------------------------------------------------
    
    -- Serial Output (MSB)
    o_Data <= r_LFSR(NUM_BITS-1);
    
    -- Parallel Output (All Bits)
    o_LFSR <= r_LFSR;    

end architecture RTL;