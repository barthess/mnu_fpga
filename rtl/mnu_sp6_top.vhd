
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;
library gtp_lib;
library i2c_lib;

entity mnu_sp6_top is
  generic (
    COMMA_8B : std_logic_vector (7 downto 0) := X"BC");  -- K28.5

  port (
    REFCLK0_N_IN : in    std_logic;     -- GTP refclk
    REFCLK0_P_IN : in    std_logic;
    FCLK         : in    std_logic;     -- fpga clock 24.84 MHz
    CSDA         : inout std_logic;     -- i2c to clock gen
    CSCL         : inout std_logic;

    RST_IN : in std_logic;              -- active low

    -- Transceiver signals
    RXN_IN  : in  std_logic_vector(3 downto 0);
    RXP_IN  : in  std_logic_vector(3 downto 0);
    TXN_OUT : out std_logic_vector(3 downto 0);
    TXP_OUT : out std_logic_vector(3 downto 0);

    -- MCU signals
    UART6_TX        : in  std_logic;
    UART6_RX        : out std_logic;
    UART6_RTS       : in  std_logic;
    UART6_CTS       : out std_logic;
    MODTELEM_RX_MNU : out std_logic;
    FPGA_NREADY     : out std_logic;    -- debug

    -- BRAM port PWM
    BRAM_TX_CLK : out std_logic;                       -- memory clock
    BRAM_TX_A   : out std_logic_vector (8 downto 0);   -- memory address
    BRAM_TX_DI  : in  std_logic_vector (15 downto 0);  -- memory data in
    BRAM_TX_DO  : out std_logic_vector (15 downto 0);  -- memory data out
    BRAM_TX_EN  : out std_logic;                       -- memory enable
    BRAM_TX_WE  : out std_logic;                       -- memory write enable
    
    -- BRAM port ICU
    BRAM_RX_CLK : out std_logic;                       -- memory clock
    BRAM_RX_A   : out std_logic_vector (8 downto 0);   -- memory address
    BRAM_RX_DI  : in  std_logic_vector (15 downto 0);  -- memory data in
    BRAM_RX_DO  : out std_logic_vector (15 downto 0);  -- memory data out
    BRAM_RX_EN  : out std_logic;                       -- memory enable
    BRAM_RX_WE  : out std_logic                        -- memory write enable
    );

end entity mnu_sp6_top;

architecture rtl of mnu_sp6_top is

  signal clk          : std_logic;      -- fpga clock 24.84
  signal rst          : std_logic;
  signal refclk0_i    : std_logic;
  signal txusrclk8_01 : std_logic;      -- TX parallel clock tile 0
  signal txusrclk8_23 : std_logic;      -- TX parallel clock tile 1
  signal rxusrclk8_0  : std_logic;      -- RX parallel clock gtp0
  signal rxusrclk8_1  : std_logic;      -- RX parallel clock gtp1
  signal rxusrclk8_2  : std_logic;      -- RX parallel clock gtp2
  signal rxusrclk8_3  : std_logic;      -- RX parallel clock gtp3

  signal gtpreset_in_i   : std_logic_vector (3 downto 0);
  signal plllkdet_out_i  : std_logic_vector (3 downto 0);  -- PLL lock
  signal resetdone_out_i : std_logic_vector (3 downto 0);

  signal rxdata0_out_i         : std_logic_vector (7 downto 0);
  signal rxdata1_out_i         : std_logic_vector (7 downto 0);
  signal rxdata2_out_i         : std_logic_vector (7 downto 0);
  signal rxdata3_out_i         : std_logic_vector (7 downto 0);
  signal rxchariscomma_out_i   : std_logic_vector (3 downto 0);
  signal rxcharisk_out_i       : std_logic_vector (3 downto 0);
  signal rxbyteisaligned_out_i : std_logic_vector (3 downto 0);
  signal rxbyterealign_out_i   : std_logic_vector (3 downto 0);
  signal rxbufstatus_out_i     : std_logic_vector (11 downto 0);

  signal txdata0_in_i      : std_logic_vector (7 downto 0);
  signal txdata1_in_i      : std_logic_vector (7 downto 0);
  signal txdata2_in_i      : std_logic_vector (7 downto 0);
  signal txdata3_in_i      : std_logic_vector (7 downto 0);
  signal txcharisk_in_i    : std_logic_vector (3 downto 0);
  signal txbufstatus_out_i : std_logic_vector (7 downto 0);

  -- Interconnect signals
  signal pwm_data_tx_i : std_logic_vector (15 downto 0);  -- to MSI
  signal pwm_en_tx_i   : std_logic;                       -- to MSI
  attribute mark_debug : string;
  attribute mark_debug of pwm_data_tx_i : signal is "TRUE";
  attribute mark_debug of pwm_en_tx_i : signal is "TRUE";
  signal uart_tx_i     : std_logic_vector (15 downto 0);  -- to MSI
  signal uart_rts_i    : std_logic_vector (15 downto 0);  -- to MSI
  signal pwm_data_rx_i : std_logic_vector (15 downto 0);  -- from MSI
  signal pwm_en_rx_i   : std_logic;                       -- from MSI
  signal uart_rx_i     : std_logic_vector (15 downto 0);  -- from MSI
  signal uart_cts_i    : std_logic_vector (15 downto 0);  -- from MSI

begin

  rst             <= not RST_IN;        -- active low button
  clk             <= FCLK;
  FPGA_NREADY     <= '0';
  MODTELEM_RX_MNU <= UART6_TX;

  gtpreset_in_i <= (others => rst);

  refclk_ibufds_i : IBUFDS
    port map
    (
      O  => refclk0_i,
      I  => REFCLK0_P_IN,
      IB => REFCLK0_N_IN
      );

  -- Clock generator I2C programming
  i2c_clkgen_prog_1 : entity i2c_lib.i2c_clkgen_prog
    port map (
      CLK => clk,
      RST => rst,
      SDA => CSDA,
      SCL => CSCL
      );

  -- RX frontend gtp0
  post_rx_mnu_0 : entity work.post_rx_mnu(gtp0)
    port map (
      clk               => rxusrclk8_0,
      rst               => rst,
      GTP_RXDATA        => rxdata0_out_i,
      GTP_CHARISK       => rxcharisk_out_i(0),
      GTP_BYTEISALIGNED => rxbyteisaligned_out_i(0),
      USART1_RX         => UART6_RX,
      USART1_CTS        => UART6_CTS,
      PWM_DATA_OUT      => open,
      PWM_EN_OUT        => open,
      UART_RX           => open,
      UART_CTS          => open);

  -- RX frontend gtp2
  post_rx_mnu_2 : entity work.post_rx_mnu(gtp2)
    generic map (
      PWM_START_CHAR => X"1C",
      PWM_CHANNELS   => 16,
      UART_CHANNELS  => 16)
    port map (
      clk               => rxusrclk8_2,
      rst               => rst,
      GTP_RXDATA        => rxdata2_out_i,
      GTP_CHARISK       => rxcharisk_out_i(2),
      GTP_BYTEISALIGNED => rxbyteisaligned_out_i(2),
      USART1_RX         => open,
      USART1_CTS        => open,
      PWM_DATA_OUT      => pwm_data_rx_i,
      PWM_EN_OUT        => pwm_en_rx_i,
      UART_RX           => uart_rx_i,
      UART_CTS          => uart_cts_i);

  -- TX frontend gtp0
  pre_tx_mnu_0 : entity work.pre_tx_mnu(gtp0)
    generic map (
      COMMA_8B       => COMMA_8B,
      COMMA_INTERVAL => 256)
    port map (
      clk           => txusrclk8_01,
      rst           => rst,
      USART1_TX     => UART6_TX,
      USART1_RTS    => UART6_RTS,
      PWM_DATA_IN   => X"0000",
      PWM_EN_IN     => '0',
      UART_TX       => X"0000",
      UART_RTS      => X"0000",
      GTP_RESETDONE => resetdone_out_i(0),
      GTP_PLLLKDET  => plllkdet_out_i(0),
      GTP_TXDATA    => txdata0_in_i,
      GTP_CHARISK   => txcharisk_in_i(0));

  -- BRAM-PWM interface
  ram_to_pwm_se_2 : entity work.ram_to_pwm_se
    port map (
      clk_tx       => txusrclk8_23,
      clk_rx       => rxusrclk8_2,
      rst          => rst,
      
      BRAM_TX_CLK  => BRAM_TX_CLK,
      BRAM_TX_A    => BRAM_TX_A,
      BRAM_TX_DI   => BRAM_TX_DI,
      BRAM_TX_DO   => BRAM_TX_DO,
      BRAM_TX_EN   => BRAM_TX_EN,
      BRAM_TX_WE   => BRAM_TX_WE,
      
      BRAM_RX_CLK  => BRAM_RX_CLK,
      BRAM_RX_A    => BRAM_RX_A,
      BRAM_RX_DI   => BRAM_RX_DI,
      BRAM_RX_DO   => BRAM_RX_DO,
      BRAM_RX_EN   => BRAM_RX_EN,
      BRAM_RX_WE   => BRAM_RX_WE,
      
      PWM_DATA_IN  => pwm_data_rx_i,    -- from MSI
      PWM_EN_IN    => pwm_en_rx_i,      -- from MSI
      PWM_DATA_OUT => pwm_data_tx_i,    -- to MSI
      PWM_EN_OUT   => pwm_en_tx_i);     -- to MSI

  -- TX frontend gtp2
  pre_tx_mnu_2 : entity work.pre_tx_mnu(gtp2)
    generic map (
      COMMA_8B       => COMMA_8B,
      PWM_START_CHAR => X"1C",          -- K28.0
      UART_CHANNELS  => 16,
      PWM_CHANNELS   => 16)
    port map (
      clk           => txusrclk8_23,
      rst           => rst,
      USART1_TX     => '0',
      USART1_RTS    => '0',
      PWM_DATA_IN   => pwm_data_tx_i,
      PWM_EN_IN     => pwm_en_tx_i,
      UART_TX       => uart_tx_i,
      UART_RTS      => uart_rts_i,
      GTP_RESETDONE => resetdone_out_i(2),
      GTP_PLLLKDET  => plllkdet_out_i(2),
      GTP_TXDATA    => txdata2_in_i,
      GTP_CHARISK   => txcharisk_in_i(2));

  sp6_gtp_top_tile0 : entity gtp_lib.sp6_gtp_top
    port map (
      REFCLK0_IN          => refclk0_i,
      GTPRESET_IN         => gtpreset_in_i (1 downto 0),
      PLLLKDET_OUT        => plllkdet_out_i (1 downto 0),
      RESETDONE_OUT       => resetdone_out_i (1 downto 0),
      RXUSRCLK8_0_OUT     => rxusrclk8_0,
      RXUSRCLK8_1_OUT     => rxusrclk8_1,
      TXUSRCLK8_OUT       => txusrclk8_01,
      RXDATA0_OUT         => rxdata0_out_i,
      RXDATA1_OUT         => rxdata1_out_i,
      RXN_IN              => RXN_IN (1 downto 0),
      RXP_IN              => RXP_IN (1 downto 0),
      RXCHARISCOMMA_OUT   => rxchariscomma_out_i (1 downto 0),
      RXCHARISK_OUT       => rxcharisk_out_i (1 downto 0),
      RXBYTEISALIGNED_OUT => rxbyteisaligned_out_i (1 downto 0),
      RXBYTEREALIGN_OUT   => rxbyterealign_out_i (1 downto 0),
      RXBUFSTATUS_OUT     => rxbufstatus_out_i (5 downto 0),
      TXDATA0_IN          => txdata0_in_i,
      TXDATA1_IN          => txdata1_in_i,
      TXN_OUT             => TXN_OUT (1 downto 0),
      TXP_OUT             => TXP_OUT (1 downto 0),
      TXCHARISK_IN        => txcharisk_in_i (1 downto 0),
      TXBUFSTATUS_OUT     => txbufstatus_out_i (3 downto 0));

  sp6_gtp_top_tile1 : entity gtp_lib.sp6_gtp_top
    port map (
      REFCLK0_IN          => refclk0_i,
      GTPRESET_IN         => gtpreset_in_i (3 downto 2),
      PLLLKDET_OUT        => plllkdet_out_i (3 downto 2),
      RESETDONE_OUT       => resetdone_out_i (3 downto 2),
      RXUSRCLK8_0_OUT     => rxusrclk8_2,
      RXUSRCLK8_1_OUT     => rxusrclk8_3,
      TXUSRCLK8_OUT       => txusrclk8_23,
      RXDATA0_OUT         => rxdata2_out_i,
      RXDATA1_OUT         => rxdata3_out_i,
      RXN_IN              => RXN_IN (3 downto 2),
      RXP_IN              => RXP_IN (3 downto 2),
      RXCHARISCOMMA_OUT   => rxchariscomma_out_i (3 downto 2),
      RXCHARISK_OUT       => rxcharisk_out_i (3 downto 2),
      RXBYTEISALIGNED_OUT => rxbyteisaligned_out_i (3 downto 2),
      RXBYTEREALIGN_OUT   => rxbyterealign_out_i (3 downto 2),
      RXBUFSTATUS_OUT     => rxbufstatus_out_i (11 downto 6),
      TXDATA0_IN          => txdata2_in_i,
      TXDATA1_IN          => txdata3_in_i,
      TXN_OUT             => TXN_OUT (3 downto 2),
      TXP_OUT             => TXP_OUT (3 downto 2),
      TXCHARISK_IN        => txcharisk_in_i (3 downto 2),
      TXBUFSTATUS_OUT     => txbufstatus_out_i (7 downto 4));

end architecture rtl;
