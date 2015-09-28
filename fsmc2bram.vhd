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
    WA : positive := 16;
    WD : positive := 16
  );
	Port (
    clk : in std_logic;

    A : in STD_LOGIC_VECTOR (WA-1 downto 0);
    D : inout STD_LOGIC_VECTOR (WD-1 downto 0);
    NWE : in STD_LOGIC;
    NOE : in STD_LOGIC;
    NCE : in STD_LOGIC;
    NBL : in std_logic_vector (1 downto 0);

    bram_a  : out STD_LOGIC_VECTOR (WA-1 downto 0);
    bram_di : in  STD_LOGIC_VECTOR (WD-1 downto 0);
    bram_do : out STD_LOGIC_VECTOR (WD-1 downto 0);
    bram_en : out STD_LOGIC := '0';
    bram_we : out std_logic_vector (1 downto 0)
  );
end fsmc2bram;

-------------------------
architecture beh of fsmc2bram is

type state_t is (IDLE, ADDR, WRITE1, READ1);
signal state : state_t := IDLE;

signal a_buf : STD_LOGIC_VECTOR (WA-1 downto 0) := (others => 'U');

begin

  D <= bram_di when (NCE = '0' and NOE = '0') else (others => 'Z');
  bram_do <= D;
  
  process(clk, NCE) begin
    if (NCE = '1') then
      bram_en <= '0';
      bram_we <= "00";
      state <= IDLE;
    elsif rising_edge(clk) then
      case state is
      when IDLE =>
        if (NCE = '0') then 
          a_buf <= A;
          state <= ADDR;
        end if;
        
      when ADDR =>
        if (NWE = '0') then
          state <= WRITE1;
        else
          state <= READ1;
          bram_en <= '1';
          a_buf  <= a_buf + 1;
          bram_a <= a_buf; 
        end if;

      when WRITE1 =>
        bram_en <= '1';
        bram_we <= not NBL;
        a_buf  <= a_buf + 1;
        bram_a  <= a_buf;

      when READ1 =>
        a_buf  <= a_buf + 1;
        bram_a <= a_buf; 

      end case;
    end if;
  end process;
end beh;




