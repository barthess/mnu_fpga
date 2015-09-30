----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:35:50 09/09/2015 
-- Design Name: 
-- Module Name:    root - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Non standard library from synopsis (for dev_null functions)
use ieee.std_logic_misc.all;

entity root is
  generic (
    FSMC_A_TOTAL_WIDTH  : positive := 23;
    FSMC_A_BLOCK_WIDTH  : positive := 12;
    FSMC_A_BLOCK_SELECT : positive := 3; 
    FSMC_D_WIDTH : positive := 16
  );
  port ( 
    CLK_IN_27MHZ : in std_logic;

    STM_UART2_RX : out std_logic;
    STM_UART2_TX : in std_logic;

    Navi_RX	: in std_logic;
    Navi_TX	: out std_logic;
    NaviNMEA_RX : in std_logic;
    NaviNMEA_TX : out std_logic;
    UBLOX_RX : out std_logic;
    UBLOX_TX : in std_logic;
    MOD_RX1	: out std_logic;
    MOD_TX1	: in std_logic;

    UBLOX_NRST :out std_logic;
    LED_LINE : out std_logic_vector (5 downto 0);

    STM_IO_GNSS_SELECT : in std_logic_vector (1 downto 0);
    STM_IO_FPGA_READY : out std_logic;

    FSMC_A : in std_logic_vector ((FSMC_A_TOTAL_WIDTH - 1) downto 0);
    FSMC_D : inout std_logic_vector ((FSMC_D_WIDTH - 1) downto 0);
    FSMC_NBL : in std_logic_vector (1 downto 0);
    FSMC_NOE : in std_logic;
    FSMC_NWE : in std_logic;
    FSMC_NCE : in std_logic;
    FSMC_CLK : in std_logic;
    
    STM_IO_MUL_RDY : out std_logic;
    STM_IO_MUL_DV : in std_logic;
    
    STM_IO_OLD_FSMC_CLK : in std_logic;
    STM_IO_7  : in std_logic;
    STM_IO_8  : in std_logic;
    STM_IO_9  : in std_logic;
    STM_IO_10 : in std_logic;
    STM_IO_11 : in std_logic;
    STM_IO_12 : in std_logic;
    STM_IO_13 : in std_logic;
    
--    SPI1_MISO : out std_logic;
--    SPI1_MOSI : in std_logic;		  
--    SPI1_NSS : in std_logic;
--    SPI1_SCK : in std_logic;

    DEV_NULL_BANK1 : out std_logic -- warning suppressor
    --DEV_NULL_BANK0 : out std_logic -- warning suppressor
	);
end root;


architecture Behavioral of root is

signal clk_10mhz  : std_logic;
signal clk_20mhz  : std_logic;
signal clk_45mhz  : std_logic;
signal clk_90mhz  : std_logic;
signal clk_180mhz : std_logic;
signal clk_360mhz : std_logic;
signal clk_locked : std_logic;

signal wire_bram_a   : std_logic_vector (8*FSMC_A_BLOCK_WIDTH-1 downto 0); 
signal wire_bram_d1  : std_logic_vector (8*FSMC_D_WIDTH-1 downto 0); 
signal wire_bram_d2  : std_logic_vector (8*FSMC_D_WIDTH-1 downto 0); 
signal wire_bram_en  : std_logic_vector (7 downto 0); 
signal wire_bram_we  : std_logic_vector (8*2-1 downto 0); 
signal wire_bram_clk : std_logic_vector (7 downto 0); 

signal fsmc_a_unused : std_logic;

begin

  assert 3 > 1 report "mram memory leak detected" severity error;

	clk_src : entity work.clk_src port map (
		CLK_IN1  => CLK_IN_27MHZ,
    
    CLK_OUT1 => clk_10mhz,
    CLK_OUT2 => clk_20mhz,
		CLK_OUT3 => clk_45mhz,
		CLK_OUT4 => clk_90mhz,
		CLK_OUT5 => clk_180mhz,
		CLK_OUT6 => clk_360mhz,
    
		LOCKED   => clk_locked
	);

  -- connect GNSS router
  gnss_router : entity work.gnss_router port map (
    sel => STM_IO_GNSS_SELECT,

    from_gnss(0) => Navi_RX,
    from_gnss(1) => NaviNMEA_RX,
    from_gnss(2) => UBLOX_TX,
    from_gnss(3) => MOD_TX1,

    to_gnss(0) => Navi_TX,
    to_gnss(1) => NaviNMEA_TX,
    to_gnss(2) => UBLOX_RX,
    to_gnss(3) => MOD_RX1,

    to_stm => STM_UART2_RX,
    from_stm => STM_UART2_TX,

    ubx_nrst => UBLOX_NRST
  );




  bram_pool : entity work.bram_pool
  generic map (
    BW => FSMC_A_BLOCK_WIDTH,
    DW => FSMC_D_WIDTH,
    count => 3
  )
  port map (
		fsmc_bram_a   => wire_bram_a  (8*FSMC_A_BLOCK_WIDTH-1 downto 5*FSMC_A_BLOCK_WIDTH),
    fsmc_bram_di  => wire_bram_d2 (8*FSMC_D_WIDTH-1 downto 5*FSMC_D_WIDTH),
    fsmc_bram_do  => wire_bram_d1 (8*FSMC_D_WIDTH-1 downto 5*FSMC_D_WIDTH),
    fsmc_bram_en  => wire_bram_en (7 downto 5),
    fsmc_bram_we  => wire_bram_we (8*2-1 downto 5*2),
    fsmc_bram_clk => wire_bram_clk(7 downto 5) 
  );





  mul_hive : entity work.mul_hive
  generic map (
    BW => FSMC_A_BLOCK_WIDTH,
    DW => FSMC_D_WIDTH,
    count => 5
  )
  port map (
    hclk => clk_90mhz,

    pin_rdy => STM_IO_MUL_RDY,
    pin_dv  => STM_IO_MUL_DV,
		
    fsmc_bram_a   => wire_bram_a  (5*FSMC_A_BLOCK_WIDTH-1 downto 0),
    fsmc_bram_di  => wire_bram_d2 (5*FSMC_D_WIDTH-1 downto 0),
    fsmc_bram_do  => wire_bram_d1 (5*FSMC_D_WIDTH-1 downto 0),
    fsmc_bram_en  => wire_bram_en (5-1   downto 0),
    fsmc_bram_we  => wire_bram_we (5*2-1 downto 0),
    fsmc_bram_clk => wire_bram_clk(5-1   downto 0) 
  );





	fsmc2bram : entity work.fsmc2bram 
  generic map (
    BW => FSMC_A_BLOCK_WIDTH,
    BS => FSMC_A_BLOCK_SELECT,
    DW => FSMC_D_WIDTH,
    AW => FSMC_A_BLOCK_WIDTH + FSMC_A_BLOCK_SELECT,
    count => 2**FSMC_A_BLOCK_SELECT
  )
  port map (
		fsmc_clk => FSMC_CLK,
    
		A => FSMC_A ((FSMC_A_BLOCK_WIDTH + FSMC_A_BLOCK_SELECT - 1) downto 0),
		D => FSMC_D,
		NCE => FSMC_NCE,
		NOE => FSMC_NOE,
		NWE => FSMC_NWE,
		NBL => FSMC_NBL,

    bram_a   => wire_bram_a,
    bram_do  => wire_bram_d2,
    bram_di  => wire_bram_d1,
    bram_en  => wire_bram_en,
    bram_we  => wire_bram_we,
    bram_clk => wire_bram_clk
	);
  fsmc_a_unused <= or_reduce (FSMC_A ((FSMC_A_TOTAL_WIDTH - 1) downto (FSMC_A_BLOCK_WIDTH + FSMC_A_BLOCK_SELECT)));
  
	-- raize ready flag
	STM_IO_FPGA_READY <= not clk_locked;

  
  
  
  
  -- warning suppressors
  LED_LINE(5 downto 0) <= (others => '0');
  
  DEV_NULL_BANK1 <= (
    fsmc_a_unused or 
    STM_IO_OLD_FSMC_CLK or
    STM_IO_MUL_DV or
    STM_IO_7 or
    STM_IO_8 or
    STM_IO_9 or
    STM_IO_10 or 
    STM_IO_11 or
    STM_IO_12 or
    STM_IO_13);

end Behavioral;

