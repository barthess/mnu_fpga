----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:19:09 10/06/2015 
-- Design Name: 
-- Module Name:    blinker - Behavioral 
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


entity blinker is
  Generic (
    AW : positive := 9; -- 512 words
    DW : positive := 16
  );
  Port (
    hclk : in STD_LOGIC;
    
    led : out std_logic;
    
    bram_a   : out STD_LOGIC_VECTOR (AW-1 downto 0);
    bram_di  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    bram_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    bram_we  : out std_logic_vector (0    downto 0);
    bram_en  : out STD_LOGIC;
    bram_clk : out std_logic
  );
end blinker;


architecture Behavioral of blinker is

--  type state_t is (LOAD1, LOAD2, LOAD3);
--  signal state : state_t := LOAD1;

  signal shadow : std_logic_vector (DW-1 downto 0);
  signal cnt : std_logic_vector (DW-1 downto 0);

begin

  bram_clk <= hckl;
  
  blink : process(hclk) begin
    if rising_edge(hclk) then
      cnt <= cnt - 1;
      if (cnt = 0) then
        cnt <= shadow + 1;
      end if;
    end if;
  end process blink;

  
  preload : process(hclk) begin
    if rising_edge(hclk) then
      bram_a <= (others => '0');
      if (cnt = 1) then
        shadow <= bram_di;
      end if;
    end if;
  end process preload;


end Behavioral;






