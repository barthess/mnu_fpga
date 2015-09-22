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
	generic(
		datlat_N : positive := 3
	);

  Port (
    clk : in std_logic;
    A : in  STD_LOGIC_VECTOR (15 downto 0);
    D : inout  STD_LOGIC_VECTOR (15 downto 0);
    NWE : in  STD_LOGIC;
    NOE : in  STD_LOGIC;
    NCE : in  STD_LOGIC;
    NBL : in std_logic_vector (1 downto 0);

    bram_a : out STD_LOGIC_VECTOR (15 downto 0);
    bram_do : in STD_LOGIC_VECTOR (15 downto 0);
    bram_di : out STD_LOGIC_VECTOR (15 downto 0);
    bram_en : out STD_LOGIC := '0';
    bram_we : out std_logic_vector (1 downto 0)
  );
end fsmc2bram;

-------------------------
architecture beh of fsmc2bram is

type state_t is (IDLE, WRITE1, WRITE2, READ1);
signal state : state_t := IDLE;

signal a_buf : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
--signal di_buf : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal datlat : integer range 0 to datlat_N := 0;

begin

  D <= bram_do when (NCE = '0' and NOE = '0') else (others => 'Z');
  bram_di <= D;
  
  --bram_we <= not NBL when (state = WRITE1 or state = WRITE2) else "00";
  bram_we <= "11" when (state = WRITE1 or state = WRITE2) else "00";

  process(clk, NCE) begin
    if (NCE = '1') then
      datlat <= 0;
      bram_en <= '0';
      state <= IDLE;
    elsif rising_edge(clk) then
      case state is
      when IDLE =>
        if (NCE = '0') then 
          a_buf <= A;
          if (NWE = '0') then
            state <= WRITE1;
          elsif (NOE = '0') then
            state <= READ1;
          end if;
        end if;

      when WRITE1 =>
        datlat <= datlat + 1;
        if (datlat = datlat_N - 2) then
          bram_en <= '1';
          state <= WRITE2;
        end if;

      when WRITE2 =>
        a_buf  <= a_buf + 1;
        bram_a  <= a_buf;

      when READ1 =>
        bram_en <= '1';
        a_buf  <= a_buf + 1;
        bram_a <= a_buf; 

      end case;
    end if;
  end process;

end beh;




