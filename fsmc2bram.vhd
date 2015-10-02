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

entity fsmc2bram is
  Generic (
    AW : positive; -- address width
    DW : positive; -- data witdth
    
    cmdaw   : positive; -- address width of single CMD region (9)
    cmdcnt  : positive; -- number of used command regions (0..2**cmdsel)
    cmdsel  : positive; -- command region select bits (3)
    
    mtrxsel : positive; -- matrix region select bits (3)    
    mtrxaw  : positive; -- address width of single matrix region (12)
    mtrxcnt : positive  -- number of used matrix regions (0..2**mtrxsel)
  );
	Port (
    fsmc_clk : in std_logic; -- extenal clock generated by FSMC bus
    mmu_int : out std_logic;
    
    A : in STD_LOGIC_VECTOR (AW-1 downto 0);
    D : inout STD_LOGIC_VECTOR (DW-1 downto 0);
    NWE : in STD_LOGIC;
    NOE : in STD_LOGIC;
    NCE : in STD_LOGIC;
    NBL : in std_logic_vector (1 downto 0);
    
--    cmd_a   : out STD_LOGIC_VECTOR (cmdcnt*cmdaw-1  downto 0);
--    cmd_di  : in  STD_LOGIC_VECTOR (cmdcnt*DW-1     downto 0);
--    cmd_do  : out STD_LOGIC_VECTOR (cmdcnt*DW-1     downto 0);
--    cmd_en  : out STD_LOGIC_vector (cmdcnt-1        downto 0);
--    cmd_we  : out std_logic_vector (cmdcnt-1        downto 0);
--    cmd_clk : out std_logic_vector (cmdcnt-1        downto 0);
    
    mtrx_a   : out STD_LOGIC_VECTOR (mtrxcnt*mtrxaw-1 downto 0);
    mtrx_di  : in  STD_LOGIC_VECTOR (mtrxcnt*DW-1     downto 0);
    mtrx_do  : out STD_LOGIC_VECTOR (mtrxcnt*DW-1     downto 0);
    mtrx_en  : out STD_LOGIC_vector (mtrxcnt-1        downto 0);
    mtrx_we  : out std_logic_vector (mtrxcnt-1        downto 0);
    mtrx_clk : out std_logic_vector (mtrxcnt-1        downto 0)
  );
  

--  function address2en(A : in std_logic_vector(AW-1 downto 0)) return std_logic_vector is
--  begin
--    return A(AW-1 downto BW);
--  end address2en;
--  
--  function address2cnt(A : in std_logic_vector(AW-1 downto 0)) return std_logic_vector is
--  begin
--    return A(BW-1 downto 0);
--  end address2cnt;

  function mmu_check(A : in std_logic_vector(AW-1 downto 0)) return std_logic is
  begin
    if A > 2**(cmdaw + cmdsel) + 2**(mtrxaw + mtrxsel) then
      return '1';
    else
      return '0';
    end if;
  end address2cnt;

end fsmc2bram;




-------------------------
architecture beh of fsmc2bram is

type state_t is (IDLE, ADDR, WRITE1, READ1);
signal state : state_t := IDLE;

signal a_cnt : STD_LOGIC_VECTOR (BW-1 downto 0) := (others => '0');

signal do_common : STD_LOGIC_VECTOR (DW-1 downto 0) := (others => '0');
signal di_common : STD_LOGIC_VECTOR (DW-1 downto 0) := (others => '0');
signal we_common : STD_LOGIC;
signal en_common : STD_LOGIC;
signal blk_select : STD_LOGIC_VECTOR (BS-1 downto 0);

begin
  
  -- fire up MMU
  mmu_int <= mmu_check(A);
  
  -- fanout connections
  fanout : for n in 0 to mtrxcnt-1 generate 
  begin
    mtrx_a  ((n+1)*BW-1 downto n*BW) <= a_cnt;
    mtrx_do ((n+1)*DW-1 downto n*DW) <= do_common;
  end generate;
  mtrx_we  <= (others => we_common);
  mtrx_clk <= (others => fsmc_clk);
  
  
  
  
  
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




