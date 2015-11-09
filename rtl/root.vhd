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

    -- bridge between Xbee modem and UART6
    -- needs only during hardware debug
    STM_UART6_TX  : in  std_logic;
    STM_UART6_RX  : out std_logic;
    STM_UART6_CTS : out std_logic;
    STM_UART6_RTS : in  std_logic;
    XBEE_TX       : in  std_logic;
    XBEE_RX       : out std_logic;
    XBEE_CTS      : out std_logic;
    XBEE_RTS      : in  std_logic;
    
--    SPI1_MISO : out std_logic;
--    SPI1_MOSI : in std_logic;		  
--    SPI1_NSS : in std_logic;
--    SPI1_SCK : in std_logic;



    -- GTP connect
    REFCLK0_N_IN : in    std_logic;     -- GTP refclk
    REFCLK0_P_IN : in    std_logic;
    FCLK         : in    std_logic;     -- fpga clock 24.84 MHz
    CSDA         : inout std_logic;     -- i2c to clock gen
    CSCL         : inout std_logic;

    RXN_IN  : in  std_logic_vector(3 downto 0);
    RXP_IN  : in  std_logic_vector(3 downto 0);
    TXN_OUT : out std_logic_vector(3 downto 0);
    TXP_OUT : out std_logic_vector(3 downto 0);
    MODTELEM_RX_MNU : out std_logic;







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

-- wires for memspace to fsmc
signal wire_bram_a   : std_logic_vector (8 downto 0); 
signal wire_bram_di  : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal wire_bram_do  : std_logic_vector (FSMC_D_WIDTH-1 downto 0); 
signal wire_bram_ce  : std_logic; 
signal wire_bram_we  : std_logic_vector (0 downto 0);  
signal wire_bram_clk : std_logic; 
signal wire_bram_asample : std_logic; 

-- wires for matrix_mul to memspace
signal wire_mulcmd_a    : std_logic_vector (8  downto 0); 
signal wire_mulcmd_di   : std_logic_vector (15 downto 0); 
signal wire_mulcmd_do   : std_logic_vector (15 downto 0); 
signal wire_mulcmd_ce   : std_logic_vector (0  downto 0);
signal wire_mulcmd_we   : std_logic_vector (0  downto 0);  
signal wire_mulcmd_clk  : std_logic_vector (0  downto 0);
signal wire_mulmtrx_a   : std_logic_vector (69 downto 0); 
signal wire_mulmtrx_di  : std_logic_vector (447 downto 0); 
signal wire_mulmtrx_do  : std_logic_vector (447 downto 0); 
signal wire_mulmtrx_ce  : std_logic_vector (6  downto 0); 
signal wire_mulmtrx_we  : std_logic_vector (6  downto 0);  
signal wire_mulmtrx_clk : std_logic_vector (6  downto 0);  

-- wires for pwm-icu to memspace
signal wire_pwmcmd_a    : std_logic_vector (8  downto 0); 
signal wire_pwmcmd_di   : std_logic_vector (15 downto 0); 
signal wire_pwmcmd_do   : std_logic_vector (15 downto 0); 
signal wire_pwmcmd_ce   : std_logic;
signal wire_pwmcmd_we   : std_logic_vector (0 downto 0);  
signal wire_pwmcmd_clk  : std_logic;


begin

  -- connect debug modem
--  STM_UART6_RX  <= XBEE_TX;
--  STM_UART6_CTS <= XBEE_RTS;
--  XBEE_RX       <= STM_UART6_TX;
--  XBEE_CTS      <= STM_UART6_RTS;
  XBEE_RX       <= XBEE_TX; -- warning suppressor
  XBEE_CTS      <= XBEE_RTS; -- warning suppressor


  -- clocking sources
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



--  ram_to_uart : entity work.ram_to_uart 
--  generic map (
--    UART_CHANNELS => 1
--  )
--  port map (
--    clk_smp  => clk_45mhz,
--    rst      => '0',
--
--    CLK_FSMC => FSMC_CLK,
--    A_IN     => FSMC_A(8 downto 0),
--    D_IN     => FSMC_D,
--    D_OUT    => open,
--    EN_IN    => not FSMC_NCE,
--    WE_IN    => not FSMC_NWE,
--
--    UART_RX  => (others => '1'),
--    UART_CTS => (others => '1'),
--    UART_TX(0) => LED_LINE(0),
--    UART_RTS => open
--  );



  mnu_sp6_top : entity work.mnu_sp6_top
  port map (
    REFCLK0_N_IN => REFCLK0_N_IN,     -- GTP refclk
    REFCLK0_P_IN => REFCLK0_P_IN,
    FCLK         => FCLK,     -- fpga clock 24.84 MHz
    CSDA         => CSDA,     -- i2c to clock gen
    CSCL         => CSCL,

    RST_IN => '1',              -- active low

    -- Transceiver signals
    RXN_IN  => RXN_IN,
    RXP_IN  => RXP_IN,
    TXN_OUT => TXN_OUT,
    TXP_OUT => TXP_OUT,

    -- MCU signals
    UART6_TX        => STM_UART6_TX,
    UART6_RX        => STM_UART6_RX,
    UART6_CTS       => STM_UART6_CTS,
    UART6_RTS       => STM_UART6_RTS,
    
    BRAM_CLK => wire_pwmcmd_clk,    -- memory clock
    BRAM_A   => wire_pwmcmd_a,      -- memory address
    BRAM_DI  => wire_pwmcmd_do,     -- memory data in
    BRAM_DO  => wire_pwmcmd_di,     -- memory data out
    BRAM_EN  => wire_pwmcmd_ce,     -- memory enable
    BRAM_WE  => wire_pwmcmd_we(0),  -- memory write enable

--    BRAM_CLK => open,
--    BRAM_A   => open,
--    BRAM_DI  => open,
--    BRAM_DO  => (others => '0'),
--    BRAM_EN  => open,
--    BRAM_WE  => open,

    MODTELEM_RX_MNU => MODTELEM_RX_MNU,
    FPGA_NREADY     => open    -- debug
  );
 




--  ram_addr_test : entity work.ram_addr_test
--  port map (
--    clk_i    => clk_180mhz,
--    BRAM_DBG => STM_IO_MUL_RDY,
--    BRAM_CLK => wire_pwmcmd_clk, -- memory clock
--    BRAM_A   => wire_pwmcmd_a,   -- memory address
--    BRAM_DI  => wire_pwmcmd_di,  -- memory data in
--    BRAM_DO  => wire_pwmcmd_do,  -- memory data out
--    BRAM_EN  => wire_pwmcmd_ce,  -- memory enable
--    BRAM_WE  => wire_pwmcmd_we(0) -- memory write enable
--  );
  




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





--  -- connect mul hive to memory space
--  mul_hive : entity work.mul_hive
--  Generic map (
--    cmdaw  => 9,  -- 9
--    cmddw  => 16, -- 16
--    mtrxaw => 10, -- 12
--    mtrxdw => 64, -- 64
--    mtrxcnt=> 7   -- 7
--  )
--  Port map (
--    --dbg => STM_IO_MUL_RDY,
--    
--    clk => clk_10mhz,
--
--    cmd_a   => wire_mulcmd_a,
--    cmd_di  => wire_mulcmd_di,
--    cmd_do  => wire_mulcmd_do,
--    cmd_ce  => wire_mulcmd_ce,
--    cmd_we  => wire_mulcmd_we,
--    cmd_clk => wire_mulcmd_clk,
--
--    mtrx_a   => wire_mulmtrx_a,
--    mtrx_di  => wire_mulmtrx_di,
--    mtrx_do  => wire_mulmtrx_do,
--    mtrx_ce  => wire_mulmtrx_ce,
--    mtrx_we  => wire_mulmtrx_we,
--    mtrx_clk => wire_mulmtrx_clk
--  );



  fsmc2bram : entity work.fsmc2bram 
    generic map (
      AW => FSMC_A_WIDTH,
      DW => FSMC_D_WIDTH,
      AWUSED => 9
    )
    port map (
      fsmc_clk => FSMC_CLK,
      mmu_int => STM_IO_MMU_INT,
      
      A   => FSMC_A,
      D   => FSMC_D,
      NCE => FSMC_NCE,
      NOE => FSMC_NOE,
      NWE => FSMC_NWE,
      NBL => FSMC_NBL,

      bram_a   => wire_bram_a,
      bram_di  => wire_bram_do,
      bram_do  => wire_bram_di,
      bram_ce  => wire_bram_ce,
      bram_we  => wire_bram_we,
      bram_clk => wire_bram_clk,
      bram_asample => wire_bram_asample
    );
    
  bram_pwm_cmd : entity work.bram_cmd
    PORT MAP (
      -- port A connected to FSMC adapter
      addra => wire_bram_a,
      dina  => wire_bram_di,
      douta => wire_bram_do,
      wea   => wire_bram_we,
      ena   => wire_bram_ce,
      clka  => wire_bram_clk,

      -- port B connected to PWM      
      addrb => wire_pwmcmd_a,
      dinb  => wire_pwmcmd_do,
      doutb => wire_pwmcmd_di,
      enb   => wire_pwmcmd_ce,
      web   => wire_pwmcmd_we,
      clkb  => wire_pwmcmd_clk
    );
    
    
    
    
    
--  memory_space : entity work.memory_space
--    generic map (
--      AWFSMC => 15, -- 15 (4096 * 8)
--      DWFSMC => 16, -- 16
--      selfsmc => 3, -- 3
--      cntfsmc => 8, -- 8
--      
--      AWCMD => 12, -- 12 (512 * 8)
--      DWCMD => 16, -- 16
--      selcmd => 3, -- 3
--      cntcmd => 8, -- 8
--
--      AWMTRXA => 15,
--      DWMTRXA => 16,
--      AWMTRXB => 10,
--      DWMTRXB => 64,
--      selmtrx => 3,
--      cntmtrx => 7
--    )
--    port map (
--      fsmc_a   => wire_bram_a,
--      fsmc_di  => wire_bram_di,
--      fsmc_do  => wire_bram_do,
--      fsmc_ce  => wire_bram_ce,
--      fsmc_we  => wire_bram_we,
--      fsmc_clk => wire_bram_clk,
--      fsmc_asample => wire_bram_asample,
--  
--      -- cmd memory region
--      cmd_a   (71  downto 18) => (others => '0'),
--      cmd_a   (17  downto 9)  => wire_pwmcmd_a,
--      cmd_a   (8   downto 0)  => wire_mulcmd_a,
--      
--      cmd_di  (127 downto 32) => (others => '0'),
--      cmd_di  (31  downto 16) => wire_pwmcmd_do,
--      cmd_di  (15  downto 0)  => wire_mulcmd_do,
--      
--      cmd_do  (127 downto 32) => open,
--      cmd_do  (31  downto 16) => wire_pwmcmd_di,
--      cmd_do  (15  downto 0)  => wire_mulcmd_di,
--      
--      cmd_ce  (7   downto 2)  => (others => '0'),
--      cmd_ce  (1)             => wire_pwmcmd_ce,
--      cmd_ce  (0)             => wire_mulcmd_ce(0),
--      
--      cmd_we  (7   downto 2)  => (others => '0'),
--      cmd_we  (1)             => wire_pwmcmd_we,
--      cmd_we  (0   downto 0)  => wire_mulcmd_we,
--      
--      cmd_clk (7   downto 2)  => (others => '0'),
--      cmd_clk (1)             => wire_pwmcmd_clk,
--      cmd_clk (0)             => wire_mulcmd_clk(0),
--  
--      -- stubs for memtest
----      cmd_a   => (others => '0'),
----      cmd_di  => (others => '0'),
----      cmd_do  => open,
----      cmd_ce  => (others => '0'),
----      cmd_we  => (others => '0'),
----      cmd_clk => (others => '0'),
--  
--      -- multiplicator matrix memory region
--      mtrx_a   => wire_mulmtrx_a,
--      mtrx_di  => wire_mulmtrx_do,
--      mtrx_do  => wire_mulmtrx_di,
--      mtrx_ce  => wire_mulmtrx_ce,
--      mtrx_we  => wire_mulmtrx_we,
--      mtrx_clk => wire_mulmtrx_clk
--      
--      -- stubs for memtest
----      mtrx_a   => (others => '0'),
----      mtrx_di  => (others => '0'),
----      mtrx_do  => open,
----      mtrx_ce  => (others => '0'),
----      mtrx_we  => (others => '0'),
----      mtrx_clk => (others => '0')
--    );



	-- raize ready flag
	STM_IO_FPGA_READY <= not clk_locked;


  -- warning suppressors
  LED_LINE(5 downto 0) <= (others => '0');

  STM_IO_MUL_RDY <= '0'; -- warning suppressor
  
  DEV_NULL_BANK1 <= (
    STM_IO_OLD_FSMC_CLK or
    STM_IO_MUL_DV or
    STM_IO_8 or
    STM_IO_9 or
    STM_IO_10 or 
    STM_IO_11 or
    STM_IO_12 or
    STM_IO_13);

end Behavioral;

