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
    FSMC_A_WIDTH : positive := 23;
    FSMC_D_WIDTH : positive := 16;
    
    cmdaw   : positive := 9;  -- address width of single CMD region
    cmdcnt  : positive := 1;  -- number of used command regions (0..2**cmdsel)
    cmdsel  : positive := 3;  -- command region select bits
    
    mtrxsel : positive := 3;  -- matrix region select bits
    mtrxaw  : positive := 12; -- address width of single matrix region
    mtrxcnt : positive := 8   -- number of used matrix regions (0..2**mtrxsel)
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

    FSMC_A : in std_logic_vector ((FSMC_A_WIDTH - 1) downto 0);
    FSMC_D : inout std_logic_vector ((FSMC_D_WIDTH - 1) downto 0);
    FSMC_NBL : in std_logic_vector (1 downto 0);
    FSMC_NOE : in std_logic;
    FSMC_NWE : in std_logic;
    FSMC_NCE : in std_logic;
    FSMC_CLK : in std_logic;
    
    STM_IO_MUL_RDY : out std_logic;
    STM_IO_MUL_DV : in std_logic;
    STM_IO_MMU_INT : out std_logic;
    STM_IO_OLD_FSMC_CLK : in std_logic;

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

-- 0..0 settings for matrix multiplier
--signal wire_cmd_a   : std_logic_vector (cmdcnt*cmdaw-1        downto 0); 
--signal wire_cmd_di  : std_logic_vector (cmdcnt*FSMC_D_WIDTH-1 downto 0); 
--signal wire_cmd_do  : std_logic_vector (cmdcnt*FSMC_D_WIDTH-1 downto 0); 
--signal wire_cmd_en  : std_logic_vector (cmdcnt-1              downto 0); 
--signal wire_cmd_we  : std_logic_vector (cmdcnt*2-1            downto 0); 
--signal wire_cmd_clk : std_logic_vector (cmdcnt-1              downto 0); 

-- 0..7 matrix buffers
signal wire_mtrx_a   : std_logic_vector (mtrxcnt*mtrxaw-1       downto 0); 
signal wire_mtrx_di  : std_logic_vector (mtrxcnt*FSMC_D_WIDTH-1 downto 0); 
signal wire_mtrx_do  : std_logic_vector (mtrxcnt*FSMC_D_WIDTH-1 downto 0); 
signal wire_mtrx_en  : std_logic_vector (mtrxcnt-1              downto 0); 
signal wire_mtrx_we  : std_logic_vector (mtrxcnt-1              downto 0); 
signal wire_mtrx_clk : std_logic_vector (mtrxcnt-1              downto 0); 



begin

  assert 1 report "mram memory leak detected" severity error;

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




--  bram_pool : entity work.bram_pool
--  generic map (
--    BW => FSMC_A_BLOCK_WIDTH,
--    DW => FSMC_D_WIDTH,
--    count => 4
--  )
--  port map (
--		fsmc_bram_a   => wire_bram_a  (8*FSMC_A_BLOCK_WIDTH-1 downto 4*FSMC_A_BLOCK_WIDTH),
--    fsmc_bram_di  => wire_bram_d2 (8*FSMC_D_WIDTH-1 downto 4*FSMC_D_WIDTH),
--    fsmc_bram_do  => wire_bram_d1 (8*FSMC_D_WIDTH-1 downto 4*FSMC_D_WIDTH),
--    fsmc_bram_en  => wire_bram_en (7 downto 4),
--    fsmc_bram_we  => wire_bram_we (8*2-1 downto 4*2),
--    fsmc_bram_clk => wire_bram_clk(7 downto 4) 
--  );
--
--
--
--
--
--  bram_mul_proxy : entity work.bram_mul_proxy
--  generic map (
--    FSMC_AW => FSMC_A_BLOCK_WIDTH,
--    FSMC_DW => FSMC_D_WIDTH,
--    MUL_AW  => FSMC_A_BLOCK_WIDTH - 2,
--    MUL_DW  => 64,
--    count   => 4
--  )
--  port map (
--    hclk => clk_90mhz,
--
--    pin_rdy => STM_IO_MUL_RDY,
--    pin_dv  => STM_IO_MUL_DV,
--		
--    fsmc_a   => wire_bram_a  (4*FSMC_A_BLOCK_WIDTH-1 downto 0),
--    fsmc_di  => wire_bram_d2 (4*FSMC_D_WIDTH-1 downto 0),
--    fsmc_do  => wire_bram_d1 (4*FSMC_D_WIDTH-1 downto 0),
--    fsmc_en  => wire_bram_en (4-1   downto 0),
--    fsmc_we  => wire_bram_we (4*2-1 downto 0),
--    fsmc_clk => wire_bram_clk(4-1   downto 0),
--    
--    mul_a   => wire_mul_a,
--    mul_di  => wire_mul_di,
--    mul_do  => wire_mul_do,
--    mul_en  => wire_mul_en,
--    mul_we  => wire_mul_we,
--    mul_clk => wire_mul_clk
--  );
--
--  mul_hive : entity work.mul_hive
--  generic map (
--    AW => FSMC_A_BLOCK_WIDTH-2,
--    DW => 64,
--    count => 4
--  )
--  port map (
--    hclk => clk_90mhz,
--
--    pin_rdy => STM_IO_MUL_RDY,
--    pin_dv  => STM_IO_MUL_DV,
--		
--    bram_a   => wire_mul_a,
--    bram_di  => wire_mul_do,
--    bram_do  => wire_mul_di,
--    bram_en  => wire_mul_en,
--    bram_we  => wire_mul_we,
--    bram_clk => wire_mul_clk
--  );





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
    mmu_int => STM_IO_MMU_INT,
    
		A => FSMC_A ((FSMC_A_BLOCK_WIDTH + FSMC_A_BLOCK_SELECT - 1) downto 0),
		D => FSMC_D,
		NCE => FSMC_NCE,
		NOE => FSMC_NOE,
		NWE => FSMC_NWE,
		NBL => FSMC_NBL,

    mtrx_a   => wire_mtrx_a,
    mtrx_di  => wire_mtrx_di,
    mtrx_do  => wire_mtrx_do,
    mtrx_en  => wire_mtrx_en,
    mtrx_we  => wire_mtrx_we,
    mtrx_clk => wire_mtrx_clk
    
--    cmd_a    => wire_cmd_a,
--    cmd_di   => wire_cmd_di,
--    cmd_do   => wire_cmd_do,
--    cmd_en   => wire_cmd_en,
--    cmd_we   => wire_cmd_we,
--    cmd_clk  => wire_cmd_clk
	);










	-- raize ready flag
	STM_IO_FPGA_READY <= not clk_locked;

  -- warning suppressors
  LED_LINE(5 downto 0) <= (others => '0');
  
  DEV_NULL_BANK1 <= (
    fsmc_a_unused or 
    STM_IO_OLD_FSMC_CLK or
    STM_IO_MUL_DV or
    STM_IO_8 or
    STM_IO_9 or
    STM_IO_10 or 
    STM_IO_11 or
    STM_IO_12 or
    STM_IO_13);

end Behavioral;

