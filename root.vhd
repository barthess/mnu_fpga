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
library UNISIM;
use UNISIM.VComponents.all;

-- Non standard library from synopsis (for dev_null functions)
use ieee.std_logic_misc.all;

entity root is
  generic (
    FSMC_A_WIDTH_TOTAL : positive := 23;
    FSMC_A_WIDTH : positive := 15;
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

    FSMC_A : in std_logic_vector (22 downto 0);
    FSMC_D : inout std_logic_vector (15 downto 0);
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

signal fsmc_bram_a  : std_logic_vector (FSMC_A_WIDTH-1-2 downto 0); 
signal fsmc_bram_do : std_logic_vector (15 downto 0); 
signal fsmc_bram_di : std_logic_vector (15 downto 0); 
signal fsmc_bram_en : std_logic; 
signal fsmc_bram_we : std_logic_vector (1 downto 0); 

signal mul2bram_d : STD_LOGIC_VECTOR (63 downto 0);
signal bram2mul_d : STD_LOGIC_VECTOR (63 downto 0);
signal mul2bram_a : STD_LOGIC_VECTOR (FSMC_A_WIDTH-1-4 downto 0);
signal mul2bram_we : STD_LOGIC_VECTOR (7 downto 0);

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


  -- connect FSMC<->BRAM
	fsmc2bram : entity work.fsmc2bram 
  generic map (
    WA => FSMC_A_WIDTH,
    WD => 16
  )
  port map (
		clk => FSMC_CLK,
    
		A => FSMC_A (FSMC_A_WIDTH-1 downto 0),
		D => FSMC_D,
		NCE => FSMC_NCE,
		NOE => FSMC_NOE,
		NWE => FSMC_NWE,
		NBL => FSMC_NBL,
    
    bram0_a  => fsmc_bram_a,
    bram0_do => fsmc_bram_do,
    bram0_di => fsmc_bram_di,
    bram0_en => fsmc_bram_en,
    bram0_we => fsmc_bram_we,
    
    bram1_a  => open,
    bram1_do => open,
    bram1_di => (others => '0'),
    bram1_en => open,
    bram1_we => open,
    
    bram2_a  => open,
    bram2_do => open,
    bram2_di => (others => '0'),
    bram2_en => open,
    bram2_we => open,
    
    bram3_a  => open,
    bram3_do => open,
    bram3_di => (others => '0'),
    bram3_en => open,
    bram3_we => open
	);
  fsmc_a_unused <= or_reduce (FSMC_A (FSMC_A_WIDTH_TOTAL-1 downto FSMC_A_WIDTH));
  
  -- Double multiplier
  multiplier : entity work.multiplier
  generic map (
    WA => FSMC_A_WIDTH-2-2
  )
  port map (
    clk => clk_180mhz,
    
    bram_do => mul2bram_d,
    bram_di => bram2mul_d,
    bram_a  => mul2bram_a,
    bram_we => mul2bram_we,
    
    pin_rdy => STM_IO_MUL_RDY,
    pin_dv  => STM_IO_MUL_DV
  );

  -- connect BRAM to all
  bram : entity work.bram 
  PORT MAP (
    clka  => FSMC_CLK,
    addra => fsmc_bram_a,
    dina  => fsmc_bram_do,
    douta => fsmc_bram_di,
    ena   => fsmc_bram_en,
    wea   => fsmc_bram_we,

    clkb  => clk_180mhz,
    web   => mul2bram_we,
    addrb => mul2bram_a,
    dinb  => mul2bram_d,
    doutb => bram2mul_d,
    enb   => '1'
  );

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

