-------------------------------------------------------------------------------
-- File : top_level_freq_counter.vhd
-- Author : Jampag
-- Date     : 2026 October 21
-- Description: Top-level of Direct Gated Frequency Counter
--  __________________________________________________________________
-- |  __________    ___________    ___________                        |
-- | |Gate_     |  |Event_latch|  |Sync_2FF   |                       |
-- | |counter   |->|           |->| u_sync_ext|---+-----------------+ |
-- | |          |  |           |  |           |   |                 | |
-- | |Clk:      |  |Clk:       |  |Clk:       |   |                 | |
-- | |Ref_Clk   |  |Ref_Clk    |  |Ext_Clk    |   |                 | |
-- | |__________|  |___________|  |___________|   |  ___________    | |
-- |                    ^                         | |Rise_      |   | |
-- |                    |   ___________           '-|detector   |   | |
-- |                    |  |Sync_2FF   |<-----------|           |   | |
-- |                    '--| u_sync_ref|  return    |Clk:       |   | |
-- |                       |           |            |Ext_Clk    |   | |
-- |                       |Clk:       |            |___________|   | |
-- |                       |Ref_Clk    |                  |         | |
-- |                       |___________|                  v         | |
-- |  ___________                                    ____________   | |
-- | |Sync_2FF   |                                  |Freq_       |  | |
-- | | u_sync_tgl|<------------- toggle ------------|counter     |<-' | 
-- | |           |                                  |            |    |
-- | |Clk:       |                                  |Clk:        |    |
-- | |Ref_Clk    |                                  |Ext_Clk     |    |
-- | |___________|                                  |____________|    |
-- |______|_________________________________________________|_________|
--        |           ^         ^         ^                 |
--        v           |         |         |                 v
--   o_Upd_toggle  i_Reset_n i_Ref_Clk i_Ext_Clk      o_Count[n:0]
--
-- Dependencies: Gate_counter.vhd; Event_latch.vhd; Sync_2FF.vhd;
--               Rise_detector.vhd; Freq_counter.vhd
-- Revision: 1.0 top_level_freq_counter.vhd
-- Additional Comments:x

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level_freq_counter is
    generic(
        G_CLOCK_FREQ    : integer := 100_000_000;
        G_CNT_BIT_DEPTH : integer := 32
    );
    Port (
        i_Reset_n    : in std_logic;
        i_Ref_Clk    : in std_logic;
        i_Ext_Clk    : in std_logic;
        o_Upd_toggle : out std_logic;
        o_Count      : out std_logic_vector(G_CNT_BIT_DEPTH - 1 downto 0)
        );
end top_level_freq_counter; 

-- Architecture
architecture behavior of top_level_freq_counter is
    
    -------------------------
    -- Component declaration
    -------------------------
    component Gate_counter
        generic(
            G_CLOCK_FREQ : integer
        );
        port(
            i_Reset : in std_logic;
            i_Clk   : in std_logic;
            o_Gate  : out std_logic
        );
    end component;
    
    component Event_latch
        port(
            i_Clk   : in std_logic;
            i_Data  : in std_logic;
            i_Reset : in std_logic;
            o_DataLatch : out std_logic
        );
    end component;

    component Sync_2FF
        port(
            i_Clk    : in std_logic; 
            i_Async  : in std_logic;
            i_Reset  : in std_logic;
            o_Sync   : out std_logic
        );
    end component;

    component Rise_detector
        port(
            i_CK     : in std_logic; 
            i_IN     : in std_logic;
            o_Pulse  : out std_logic
        );
    end component;
    
    component Freq_counter
        generic(
            G_BIT_DEPTH : integer
        );
        port(             
            i_Reset      : in std_logic;
            i_Clk_ext    : in std_logic;
            o_count      : out std_logic_vector(G_BIT_DEPTH - 1 downto 0 );
            o_upd_toggle : out std_logic
        );
    end component;    
    
    --------------------
    -- Internal signals
    --------------------
    -- i_Ref_Clk domain
    signal gate_pulse    : std_logic;
    signal gate_latched  : std_logic;
    signal gate_sync_ref : std_logic;
    
    -- i_Ext_Clk domain
    signal gate_sync_ext  : std_logic;
    signal reset_pulse    : std_logic;
    signal upd_toggle_ext : std_logic;

 begin

    -----------------------
    -- Gate counter
    -----------------------
    u_gate: Gate_counter
        generic map(
            G_CLOCK_FREQ => G_CLOCK_FREQ
        )
        port map(
            i_Reset => i_Reset_n,
            i_Clk   => i_Ref_Clk,
            o_Gate  => gate_pulse
        );

    -----------------------
    -- Event latch [1]
    -----------------------
    u_latch: Event_latch
        port map(
            i_Clk   => i_Ref_Clk,
            i_Data  => gate_pulse,
            i_Reset => gate_sync_ref,
            o_DataLatch => gate_latched
        );

    -----------------------------
    -- Sync_2FF to i_Ext_Clk [4]
    -----------------------------
    u_sync_ext: Sync_2FF
        port map(
            i_Clk   => i_Ext_Clk,
            i_Async => gate_latched,
            i_Reset => i_Reset_n,
            o_Sync  => gate_sync_ext
        );
 
    ----------------------------------------------------------
    -- Sync_2FF to i_Ref_Clk reset Event_latch, handshake [2]
    ----------------------------------------------------------
    u_sync_ref: Sync_2FF
        port map(
            i_Clk   => i_Ref_Clk,
            i_Async => gate_sync_ext,
            i_Reset => i_Reset_n,
            o_Sync  => gate_sync_ref
        );

    ----------------------------
    -- Rising edge detector [3]
    ----------------------------
    u_rise_detect: Rise_detector
        port map(
            i_CK    => i_Ext_Clk,
            i_IN    => gate_sync_ext,
            o_Pulse => reset_pulse
        );        

    ----------------------
    -- Frequency counter
    ----------------------
    u_cnt_freq: Freq_counter
        generic map(
            G_BIT_DEPTH => G_CNT_BIT_DEPTH
        )
        port map(
            i_Reset      => reset_pulse,
            i_Clk_ext    => i_Ext_Clk,
            o_count      => o_Count,
            o_upd_toggle => upd_toggle_ext
        );
        
    --------------------------------------------
    -- Sync_2FF upd_toggle_ext to i_Ref_Clk [5]
    --------------------------------------------
    u_sync_tgl: Sync_2FF
        port map(
            i_Clk   => i_Ref_Clk,
            i_Async => upd_toggle_ext,
            i_Reset => i_Reset_n,
            o_Sync  => o_Upd_toggle
        );     
        
end behavior;