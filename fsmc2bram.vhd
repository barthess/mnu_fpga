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
    WA : positive;
    WD : positive
  );
	Port (
    clk : in std_logic;

    A : in STD_LOGIC_VECTOR (WA-1 downto 0);
    D : inout STD_LOGIC_VECTOR (WD-1 downto 0);
    NWE : in STD_LOGIC;
    NOE : in STD_LOGIC;
    NCE : in STD_LOGIC;
    NBL : in std_logic_vector (1 downto 0);

    bram0_a  : out STD_LOGIC_VECTOR (WA-1-2 downto 0);
    bram0_di : in  STD_LOGIC_VECTOR (WD-1 downto 0);
    bram0_do : out STD_LOGIC_VECTOR (WD-1 downto 0);
    bram0_en : out STD_LOGIC;
    bram0_we : out std_logic_vector (1 downto 0);
    
    bram1_a  : out STD_LOGIC_VECTOR (WA-1-2 downto 0);
    bram1_di : in  STD_LOGIC_VECTOR (WD-1 downto 0);
    bram1_do : out STD_LOGIC_VECTOR (WD-1 downto 0);
    bram1_en : out STD_LOGIC;
    bram1_we : out std_logic_vector (1 downto 0);
    
    bram2_a  : out STD_LOGIC_VECTOR (WA-1-2 downto 0);
    bram2_di : in  STD_LOGIC_VECTOR (WD-1 downto 0);
    bram2_do : out STD_LOGIC_VECTOR (WD-1 downto 0);
    bram2_en : out STD_LOGIC;
    bram2_we : out std_logic_vector (1 downto 0);
    
    bram3_a  : out STD_LOGIC_VECTOR (WA-1-2 downto 0);
    bram3_di : in  STD_LOGIC_VECTOR (WD-1 downto 0);
    bram3_do : out STD_LOGIC_VECTOR (WD-1 downto 0);
    bram3_en : out STD_LOGIC;
    bram3_we : out std_logic_vector (1 downto 0)
  );
end fsmc2bram;

-------------------------
architecture beh of fsmc2bram is

type state_t is (IDLE, ADDR, WRITE1, READ1);
signal state : state_t := IDLE;

signal a_cnt : STD_LOGIC_VECTOR (WA-1 downto 0) := (others => '0');

signal bram_a_common  : STD_LOGIC_VECTOR (WA-1 downto 0) := (others => '0');
signal bram_do_common : STD_LOGIC_VECTOR (WD-1 downto 0) := (others => '0');
signal bram_di_common : STD_LOGIC_VECTOR (WD-1 downto 0) := (others => '0');
signal bram_we_common : STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
signal bram_en_common : STD_LOGIC := '0';
signal blk_select : STD_LOGIC_VECTOR (1 downto 0);

begin

  bram0_a  <= bram_a_common(WA-1-2 downto 0);
  bram1_a  <= bram_a_common(WA-1-2 downto 0);
  bram2_a  <= bram_a_common(WA-1-2 downto 0);
  bram3_a  <= bram_a_common(WA-1-2 downto 0);

  bram0_we <= bram_we_common;
  bram1_we <= bram_we_common;
  bram2_we <= bram_we_common;
  bram3_we <= bram_we_common;

  bram0_do <= bram_do_common;
  bram1_do <= bram_do_common;
  bram2_do <= bram_do_common;
  bram3_do <= bram_do_common;

  blk_select <= bram_a_common(WA-1 downto WA-2);
  
  "FIXME: enable must be sycronouse"
  en_decoder : entity work.fsmc_2to4_en
  PORT MAP (
    A  => blk_select,
    en => bram_en_common,
    
    sel(0) => bram0_en,
    sel(1) => bram1_en,
    sel(2) => bram2_en,
    sel(3) => bram3_en
  );

  di_decoder : entity work.fsmc_2to4_di
  PORT MAP (
    A  => blk_select,

    di0 => bram0_di,
    di1 => bram1_di,
    di2 => bram2_di,
    di3 => bram3_di,
    
    do  => bram_di_common
  );

  D <= bram_di_common when (NCE = '0' and NOE = '0') else (others => 'Z');
  bram_do_common <= D;
  
  process(clk, NCE) begin
    if (NCE = '1') then
      bram_en_common <= '0';
      bram_we_common <= "00";
      state <= IDLE;
    elsif rising_edge(clk) then
      case state is
      when IDLE =>
        if (NCE = '0') then 
          a_cnt <= A;
          state <= ADDR;
        end if;
        
      when ADDR =>
        if (NWE = '0') then
          state <= WRITE1;
        else
          state <= READ1;
          bram_en_common <= '1';
          a_cnt <= a_cnt + 1;
          bram_a_common <= a_cnt; 
        end if;

      when WRITE1 =>
        bram_en_common <= '1';
        bram_we_common <= not NBL;
        a_cnt <= a_cnt + 1;
        bram_a_common <= a_cnt;

      when READ1 =>
        a_cnt <= a_cnt + 1;
        bram_a_common <= a_cnt;

      end case;
    end if;
  end process;
end beh;




