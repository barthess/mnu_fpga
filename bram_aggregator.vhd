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
    
    sel : positive; -- number bits used for slave addressing
    slavecnt : positive -- number of actually realized outputs
  );
  Port (
    mmu_int : out std_logic;

    a   : in STD_LOGIC_VECTOR (AW-1 downto 0);
    do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    di  : in STD_LOGIC_VECTOR (DW-1 downto 0);
    we  : in STD_LOGIC;
    ce  : in STD_LOGIC;
    clk : in std_logic;
    
    slave_a   : out STD_LOGIC_VECTOR (slavecnt*(AW-sel)-1    downto 0);
    slave_di  : in  STD_LOGIC_VECTOR (slavecnt*DW-1 downto 0);
    slave_do  : out STD_LOGIC_VECTOR (slavecnt*DW-1 downto 0);
    slave_en  : out STD_LOGIC_vector (slavecnt-1    downto 0);
    slave_we  : out std_logic_vector (slavecnt-1    downto 0);
    slave_clk : out std_logic_vector (slavecnt-1    downto 0)
  );
  

  function get_select(A : in std_logic_vector(AW-1 downto 0)) return std_logic_vector is
  begin
    return A(AW-1 downto AW-sel);
  end address2en;

--  function address2cnt(A : in std_logic_vector(AW-1 downto 0)) return std_logic_vector is
--  begin
--    return A(BW-1 downto 0);
--  end address2cnt;

  function mmu_check(A : in std_logic_vector(AW-1 downto 0)) return std_logic is
  begin
    if get_select(A) + 1 > slavecnt then
      return '1';
    else
      return '0';
    end if;
  end address2cnt;

end bram_aggregator;




-------------------------
architecture beh of bram_aggregator is

signal do_common : STD_LOGIC_VECTOR (DW-1 downto 0) := (others => '0');
signal di_common : STD_LOGIC_VECTOR (DW-1 downto 0) := (others => '0');
signal we_common : STD_LOGIC;
signal en_common : STD_LOGIC;
signal blk_select : STD_LOGIC_VECTOR (BS-1 downto 0);

constant slaveaw : positive := AW - sel;

begin
  
  -- fire up memory check
  mmu_int <= mmu_check(A);
  
  -- fanout connections
  fanout : for n in 0 to slavecnt-1 generate 
  begin
    slave_a  ((n+1)*slaveaw-1 downto n*slaveaw) <= a(slaveaw-1 downto 0);
    slave_do ((n+1)*DW-1 downto n*DW) <= do;
  end generate;
  
  
  
  
  
  en_demux : entity work.demuxer
  generic map (
    AW => BS,
    DW => 1
  )
  PORT MAP (
    A    => blk_select,
    i(0) => en_common,
    o    => bram_en
  );



  di_mux : entity work.muxer
  generic map (
    AW => BS,
    DW => DW
  )
  PORT MAP (
    A => blk_select,
    i => bram_di,
    o => di_common
  );



  D <= di_common when (NCE = '0' and NOE = '0') else (others => 'Z');
  do_common <= D;
  
  
  
  process(fsmc_clk, NCE) begin
    if (NCE = '1') then
      en_common <= '0';
      we_common <= "00";
      state <= IDLE;
      
    elsif rising_edge(fsmc_clk) then
      case state is
      
      when IDLE =>
        if (NCE = '0') then 
          a_cnt <= address2cnt(A);
          blk_select <= address2en(A);
          state <= ADDR;
        end if;
        
      when ADDR =>
        if (NWE = '0') then
          state <= WRITE1;
        else
          state <= READ1;
          en_common <= '1';
          a_cnt <= a_cnt + 1;
        end if;

      when WRITE1 =>
        en_common <= '1';
        we_common <= not NBL;
        a_cnt <= a_cnt + 1;

      when READ1 =>
        a_cnt <= a_cnt + 1;

      end case;
    end if;
  end process;
end beh;




