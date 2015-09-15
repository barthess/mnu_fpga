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
		--FSMC_CLK : in std_logic;
		--FSMC_NWAIT : out std_logic;

--		SPI1_MISO : out std_logic;
--		SPI1_MOSI : in std_logic;		  
--		SPI1_NSS : in std_logic;
--		SPI1_SCK : in std_logic;
		  
		DEV_NULL_B1 : out std_logic; -- warning suppressor
    DEV_NULL_B0 : out std_logic -- warning suppressor
	);
end root;




architecture Behavioral of root is

signal clk_98mhz  : std_logic;
signal clk_196mhz : std_logic;
signal clk_261mhz : std_logic;
signal clk_391mhz : std_logic;
signal clk_locked : std_logic;

signal mem_do : std_logic_vector (15 downto 0);
signal mem_di : std_logic_vector (15 downto 0);
signal mem_a  : std_logic_vector (15 downto 0);
signal mem_we : std_logic_vector (1 downto 0);
signal mem_en : std_logic;

begin

	clk_src : entity work.clk_src port map (
		CLK_IN1  => CLK_IN_27MHZ,
		CLK_OUT1 => clk_391mhz,
		CLK_OUT2 => clk_261mhz,
		CLK_OUT3 => clk_196mhz,
		CLK_OUT4 => clk_98mhz,
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


  -- connect bram
  bram : entity work.bram_fsmc PORT MAP (
    clka => clk_391MHz,
    ena => mem_en,
    wea => mem_we,
    addra => mem_a,
    dina => mem_di,
    douta => mem_do,
    
    clkb => clk_391MHz,
    enb => '1',
    web => (others => '0'),
    addrb => (others => '0'),
    dinb => (others => '0'),
    doutb => open
  );
  DEV_NULL_B0 <= or_reduce(mem_di);


  -- connect FSMC
	fsmc : entity work.fsmc port map (
		hclk => clk_391MHz, 
		A => FSMC_A(15 downto 0),
		D => FSMC_D,
		NCE => FSMC_NCE,
		NOE => FSMC_NOE,
		NWE => FSMC_NWE,
		NBL => FSMC_NBL,
    
    mem_do => mem_do,
    mem_di => mem_di,
    mem_a  => mem_a,
    mem_we => mem_we,
    mem_en => mem_en
	);
	DEV_NULL_B1 <= or_reduce(FSMC_A(22 downto 16));

    -- double multiplier test
--	mul_test : entity work.mul_test port map (
--		clk => clk_391mhz,
--        fake_out => DEV_NULL_B0
--	);

    LED_LINE <= (others => '0');
    
	-- raize ready flag
	STM_IO_FPGA_READY <= not clk_locked;

end Behavioral;

