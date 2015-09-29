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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

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

signal bram0_a  : std_logic_vector (FSMC_A_BLOCK_WIDTH-1 downto 0); 
signal bram0_d1 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram0_d2 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram0_en : std_logic; 
signal bram0_we : std_logic_vector (1 downto 0); 
signal bram0_clk : std_logic; 

signal bram1_a  : std_logic_vector (FSMC_A_BLOCK_WIDTH-1 downto 0); 
signal bram1_d1 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram1_d2 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram1_en : std_logic; 
signal bram1_we : std_logic_vector (1 downto 0); 
signal bram1_clk : std_logic; 

signal bram2_a  : std_logic_vector (FSMC_A_BLOCK_WIDTH-1 downto 0); 
signal bram2_d1 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram2_d2 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram2_en : std_logic; 
signal bram2_we : std_logic_vector (1 downto 0); 
signal bram2_clk : std_logic; 

signal bram3_a  : std_logic_vector (FSMC_A_BLOCK_WIDTH-1 downto 0); 
signal bram3_d1 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram3_d2 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram3_en : std_logic; 
signal bram3_we : std_logic_vector (1 downto 0); 
signal bram3_clk : std_logic; 

signal bram4_a  : std_logic_vector (FSMC_A_BLOCK_WIDTH-1 downto 0); 
signal bram4_d1 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram4_d2 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram4_en : std_logic; 
signal bram4_we : std_logic_vector (1 downto 0); 
signal bram4_clk : std_logic; 

signal bram5_a  : std_logic_vector (FSMC_A_BLOCK_WIDTH-1 downto 0); 
signal bram5_d1 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram5_d2 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram5_en : std_logic; 
signal bram5_we : std_logic_vector (1 downto 0); 
signal bram5_clk : std_logic; 

signal bram6_a  : std_logic_vector (FSMC_A_BLOCK_WIDTH-1 downto 0); 
signal bram6_d1 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram6_d2 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram6_en : std_logic; 
signal bram6_we : std_logic_vector (1 downto 0); 
signal bram6_clk : std_logic; 

signal bram7_a  : std_logic_vector (FSMC_A_BLOCK_WIDTH-1 downto 0); 
signal bram7_d1 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram7_d2 : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal bram7_en : std_logic; 
signal bram7_we : std_logic_vector (1 downto 0); 
signal bram7_clk : std_logic; 



signal fsmc_a_unused : std_logic;

begin

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
    DW => FSMC_D_WIDTH
  )
  port map (
		fsmc_bram4_a   => bram4_a,
    fsmc_bram4_di  => bram4_d2,
    fsmc_bram4_do  => bram4_d1,
    fsmc_bram4_en  => bram4_en,
    fsmc_bram4_we  => bram4_we,
    fsmc_bram4_clk => bram4_clk,
    
		fsmc_bram5_a   => bram5_a,
    fsmc_bram5_di  => bram5_d2,
    fsmc_bram5_do  => bram5_d1,
    fsmc_bram5_en  => bram5_en,
    fsmc_bram5_we  => bram5_we,
    fsmc_bram5_clk => bram5_clk,

		fsmc_bram6_a   => bram6_a,
    fsmc_bram6_di  => bram6_d2,
    fsmc_bram6_do  => bram6_d1,
    fsmc_bram6_en  => bram6_en,
    fsmc_bram6_we  => bram6_we,
    fsmc_bram6_clk => bram6_clk,

		fsmc_bram7_a   => bram7_a,
    fsmc_bram7_di  => bram7_d2,
    fsmc_bram7_do  => bram7_d1,
    fsmc_bram7_en  => bram7_en,
    fsmc_bram7_we  => bram7_we,
    fsmc_bram7_clk => bram7_clk
  );



  mul_hive : entity work.mul_hive
  generic map (
    BW => FSMC_A_BLOCK_WIDTH,
    DW => FSMC_D_WIDTH
  )
  port map (
    hclk => clk_180mhz,

    pin_rdy => STM_IO_MUL_RDY,
    pin_dv  => STM_IO_MUL_DV,

		fsmc_bram0_a   => bram0_a,
    fsmc_bram0_di  => bram0_d2,
    fsmc_bram0_do  => bram0_d1,
    fsmc_bram0_en  => bram0_en,
    fsmc_bram0_we  => bram0_we,
    fsmc_bram0_clk => bram0_clk,
    
		fsmc_bram1_a   => bram1_a,
    fsmc_bram1_di  => bram1_d2,
    fsmc_bram1_do  => bram1_d1,
    fsmc_bram1_en  => bram1_en,
    fsmc_bram1_we  => bram1_we,
    fsmc_bram1_clk => bram1_clk,

		fsmc_bram2_a   => bram2_a,
    fsmc_bram2_di  => bram2_d2,
    fsmc_bram2_do  => bram2_d1,
    fsmc_bram2_en  => bram2_en,
    fsmc_bram2_we  => bram2_we,
    fsmc_bram2_clk => bram2_clk,

		fsmc_bram3_a   => bram3_a,
    fsmc_bram3_di  => bram3_d2,
    fsmc_bram3_do  => bram3_d1,
    fsmc_bram3_en  => bram3_en,
    fsmc_bram3_we  => bram3_we,
    fsmc_bram3_clk => bram3_clk
  );



	fsmc2bram : entity work.fsmc2bram 
  generic map (
    BW => FSMC_A_BLOCK_WIDTH,
    BS => FSMC_A_BLOCK_SELECT,
    DW => 16,
    AW => FSMC_A_BLOCK_WIDTH + FSMC_A_BLOCK_SELECT
  )
  port map (
		fsmc_clk => FSMC_CLK,
    
		A => FSMC_A ((FSMC_A_BLOCK_WIDTH + FSMC_A_BLOCK_SELECT - 1) downto 0),
		D => FSMC_D,
		NCE => FSMC_NCE,
		NOE => FSMC_NOE,
		NWE => FSMC_NWE,
		NBL => FSMC_NBL,

    bram0_a   => bram0_a,
    bram0_do  => bram0_d2,
    bram0_di  => bram0_d1,
    bram0_en  => bram0_en,
    bram0_we  => bram0_we,
    bram0_clk => bram0_clk,
    
    bram1_a   => bram1_a,
    bram1_do  => bram1_d2,
    bram1_di  => bram1_d1,
    bram1_en  => bram1_en,
    bram1_we  => bram1_we,
    bram1_clk => bram1_clk,
    
    bram2_a   => bram2_a,
    bram2_do  => bram2_d2,
    bram2_di  => bram2_d1,
    bram2_en  => bram2_en,
    bram2_we  => bram2_we,
    bram2_clk => bram2_clk,
    
    bram3_a   => bram3_a,
    bram3_do  => bram3_d2,
    bram3_di  => bram3_d1,
    bram3_en  => bram3_en,
    bram3_we  => bram3_we,
    bram3_clk => bram3_clk,

    bram4_a   => bram4_a,
    bram4_do  => bram4_d2,
    bram4_di  => bram4_d1,
    bram4_en  => bram4_en,
    bram4_we  => bram4_we,
    bram4_clk => bram4_clk,

    bram5_a   => bram5_a,
    bram5_do  => bram5_d2,
    bram5_di  => bram5_d1,
    bram5_en  => bram5_en,
    bram5_we  => bram5_we,
    bram5_clk => bram5_clk,

    bram6_a   => bram6_a,
    bram6_do  => bram6_d2,
    bram6_di  => bram6_d1,
    bram6_en  => bram6_en,
    bram6_we  => bram6_we,
    bram6_clk => bram6_clk,

    bram7_a   => bram7_a,
    bram7_do  => bram7_d2,
    bram7_di  => bram7_d1,
    bram7_en  => bram7_en,
    bram7_we  => bram7_we,
    bram7_clk => bram7_clk
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

