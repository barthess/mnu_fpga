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

entity root is
    port ( 
		CLK_IN1 : in std_logic; -- 27MHz
        
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
		STM_IO6 : out std_logic;
		  
		FSMC_A : in std_logic_vector (22 downto 0);
		FSMC_D : inout std_logic_vector (15 downto 0);
		FSMC_NBL : in std_logic_vector (1 downto 0);
		FSMC_NOE : in std_logic;
		FSMC_NWE : in std_logic;
		FSMC_NCE : in std_logic;
		FSMC_CLK : in std_logic;
		FSMC_NWAIT : out std_logic;
		  
		SPI1_NSS : in std_logic;
		SPI1_SCK : in std_logic;
		SPI1_MISO : out std_logic;
		SPI1_MOSI : in std_logic;
		  
		DEV_NULL_B1 : out std_logic -- warning suppressor
	);
end root;




architecture Behavioral of root is

begin

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

	-- raize ready flag
	--STM_IO_FPGA_READY <= not clk_locked;
    STM_IO_FPGA_READY <= '0';

end Behavioral;

