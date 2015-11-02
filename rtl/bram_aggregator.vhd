----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:43:03 07/21/2015 
-- Design Name: 
-- Module Name:    fsmc_glue - A_fsmc_glue 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bram_aggregator is
  Generic (
    AW : positive; -- input address width
    DW : positive; -- data witdth
    sel : positive; -- number of bits used for slave addressing
    slavecnt : positive -- number of actually realized outputs
  );
  Port (
    A   : in  STD_LOGIC_VECTOR (AW-1 downto 0);
    DO  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    DI  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    WE  : in  STD_LOGIC_VECTOR (0 downto 0);
    CE  : in  STD_LOGIC;
    CLK : in  std_logic;
    ASAMPLE : in STD_LOGIC; -- address sample strobe. Must be high during 1 clock period
    
    slave_a   : out STD_LOGIC_VECTOR (slavecnt*(AW-sel)-1 downto 0);
    slave_di  : in  STD_LOGIC_VECTOR (slavecnt*DW-1       downto 0);
    slave_do  : out STD_LOGIC_VECTOR (slavecnt*DW-1       downto 0);
    slave_ce  : out STD_LOGIC_vector (slavecnt-1          downto 0);
    slave_we  : out std_logic_vector (slavecnt-1          downto 0);
    slave_clk : out std_logic_vector (slavecnt-1          downto 0)
  );
  
  --
  function get_select(A : in std_logic_vector(AW-1 downto 0)) return std_logic_vector is
  begin
    return A(AW-1 downto AW-sel);
  end get_select;

end bram_aggregator;


---------------------------------------------

architecture beh of bram_aggregator is

constant slaveaw : positive := AW - sel;
signal select_sample : std_logic_vector(sel-1 downto 0);

begin
  
  -- fanout bus connections
  fanout : for n in 0 to slavecnt-1 generate 
  begin
    slave_a  ((n+1)*slaveaw-1 downto n*slaveaw) <= A(slaveaw-1 downto 0);
    slave_do ((n+1)*DW-1 downto n*DW) <= DI;
  end generate;
  slave_clk <= (others => CLK);
  
  -- clock enable fanout
  ce_demux : entity work.demuxer
    generic map (
      AW => sel,
      DW => 1,
      cnt => slavecnt
    )
    PORT MAP (
      A     => select_sample,
      di(0) => CE,
      do    => slave_ce
    );

  -- write enable fanout
  we_demux : entity work.demuxer
  generic map (
    AW => sel,
    DW => 1,
    cnt => slavecnt
  )
  PORT MAP (
    A  => select_sample,
    di => WE,
    do => slave_we
  );

  -- data bus output fanout
  di_mux : entity work.muxer
  generic map (
    AW => sel,
    DW => DW,
    cnt => slavecnt
  )
  PORT MAP (
    A => select_sample,
    di => slave_di,
    do => DO
  );

  -- 
  process(CLK) begin
    if rising_edge(CLK) then
      if (ASAMPLE = '1') then
        select_sample <= get_select(A);
      end if;
    end if;
  end process;

end beh;




