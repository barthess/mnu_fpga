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
    AW : positive; -- total FSMC address width
    DW : positive; -- data witdth
    AWSPARE : positive -- unused address lines
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
    
    bram_a   : out STD_LOGIC_VECTOR (AW-AWSPARE-1 downto 0);
    bram_di  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    bram_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    bram_en  : out STD_LOGIC;
    bram_we  : out STD_LOGIC_VECTOR (0 downto 0);
    bram_clk : out std_logic;
    bram_asample : out STD_LOGIC
  );
  

  -- just cut out unused lines from address bus
  function address2cnt(A : in std_logic_vector(AW-1 downto 0)) return std_logic_vector is
  begin
    return A(AW-AWSPARE-1 downto 0);
  end address2cnt;

  -- MMU check routine. Must be called when addres sampled
  function mmu_check(A   : in std_logic_vector(AW-1 downto 0);
                     NBL : in std_logic_vector(1 downto 0)) 
                     return std_logic is
  begin
    if A > 2**(AW-AWSPARE) and (NBL(0) = NBL(1)) then
      return '1';
    else
      return '0';
    end if;
  end mmu_check;

end fsmc2bram;



-----------------------------------------------------------------------------

architecture beh of fsmc2bram is

type state_t is (IDLE, ADDR, WRITE1, READ1);
signal state : state_t := IDLE;

signal a_cnt : STD_LOGIC_VECTOR (AW-AWSPARE-1 downto 0) := (others => '0');

begin

  -- connect permanent signals
  bram_clk <= fsmc_clk;
  bram_a   <= a_cnt;

  -- coonect 3-state data bus
  D <= bram_di when (NCE = '0' and NOE = '0') else (others => 'Z');
  bram_do <= D;

  -- main process
  process(fsmc_clk, NCE) begin
    if (NCE = '1') then
      bram_en <= '0';
      bram_we <= "0";
      mmu_int <= '0';
      state <= IDLE;
      
    elsif rising_edge(fsmc_clk) then
      case state is
      
      when IDLE =>
        if (NCE = '0') then 
          a_cnt <= address2cnt(A);
          bram_asample <= '1';
          mmu_int <= mmu_check(A, NBL);
          state <= ADDR;
        end if;
        
      when ADDR =>
        bram_asample <= '0';
        if (NWE = '0') then
          state <= WRITE1;
        else
          state <= READ1;
          bram_en <= '1';
          a_cnt <= a_cnt + 1;
        end if;

      when WRITE1 =>
        bram_en <= '1';
        --bram_we <= not NBL;
        bram_we <= "1";
        a_cnt <= a_cnt + 1;

      when READ1 =>
        a_cnt <= a_cnt + 1;

      end case;
    end if;
  end process;
end beh;




