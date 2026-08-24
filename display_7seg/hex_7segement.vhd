-------------------------------------------------------------------------------
-- File     : hex_7segement.vhd
-- Author   : Jampag
-- Date     : 2026 August 21
-- Revision : 1.0 
-- Description:
--  7-Segment Display Controller (Binary to Hexadecimal Decoder)
--  Maps 4-bit input (0000 to 1111) to: 
--   0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, b, C, d, E, F
-- Block Diagram: 
--
--   [ VCC for Common Anode ] / [ GND for Common Cathode ]
--                            |
--                         --- A ---
--                        |         |
--                      F |         | B
--                        |--- G ---|
--                      E |         | C
--                        |         |
--                         --- D ---
--
-- Dependencies: x
-- Note: x

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hex_7segment is
    Generic (
        COMMON_ANODE : boolean := false -- true = common anode, false = common cathode
    );
    Port ( 
        i_Clk       : in  std_logic;
        i_Bin_Num   : in  std_logic_vector(3 downto 0);
        o_Segment_A : out std_logic;
        o_Segment_B : out std_logic;
        o_Segment_C : out std_logic;
        o_Segment_D : out std_logic;
        o_Segment_E : out std_logic;
        o_Segment_F : out std_logic;
        o_Segment_G : out std_logic
    );
end hex_7segment;

architecture Behavioral of hex_7segment is
    signal r_encoding : std_logic_vector (6 downto 0); 
begin

    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            case i_Bin_Num is 
                when "0000" => r_encoding <= "1111110"; -- 0
                when "0001" => r_encoding <= "0110000"; -- 1
                when "0010" => r_encoding <= "1101101"; -- 2
                when "0011" => r_encoding <= "1111001"; -- 3
                when "0100" => r_encoding <= "0110011"; -- 4
                when "0101" => r_encoding <= "1011011"; -- 5
                when "0110" => r_encoding <= "1011111"; -- 6
                when "0111" => r_encoding <= "1110000"; -- 7
                when "1000" => r_encoding <= "1111111"; -- 8
                when "1001" => r_encoding <= "1111011"; -- 9
                when "1010" => r_encoding <= "1110111"; -- A
                when "1011" => r_encoding <= "0011111"; -- b
                when "1100" => r_encoding <= "1001110"; -- C
                when "1101" => r_encoding <= "0111101"; -- d
                when "1110" => r_encoding <= "1001111"; -- E
                when "1111" => r_encoding <= "1000111"; -- F
                when others => r_encoding <= "0000000";
            end case;
        end if;    
    end process;

    o_Segment_A <= not r_encoding(6) when COMMON_ANODE else r_encoding(6);
    o_Segment_B <= not r_encoding(5) when COMMON_ANODE else r_encoding(5);
    o_Segment_C <= not r_encoding(4) when COMMON_ANODE else r_encoding(4);
    o_Segment_D <= not r_encoding(3) when COMMON_ANODE else r_encoding(3);
    o_Segment_E <= not r_encoding(2) when COMMON_ANODE else r_encoding(2);
    o_Segment_F <= not r_encoding(1) when COMMON_ANODE else r_encoding(1);
    o_Segment_G <= not r_encoding(0) when COMMON_ANODE else r_encoding(0);

end Behavioral;
