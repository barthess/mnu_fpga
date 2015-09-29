----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:11:18 09/28/2015 
-- Design Name: 
-- Module Name:    fsmc_3to8_decoder - Behavioral 
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

entity fsmc_3to8_en is
  port(
    A   : in  STD_LOGIC_VECTOR(2 downto 0);
    en  : in  std_logic;
    sel : out STD_LOGIC_VECTOR(7 downto 0) := "00000000"
  );
end fsmc_3to8_en;

architecture Behavioral of fsmc_3to8_en is

begin

  process(en, A) begin
    if (en = '1') then
      case A is
        when "000" =>
          sel <= "00000001"; 
        when "001" =>
          sel <= "00000010";
        when "010" =>
          sel <= "00000100";
        when "011" =>
          sel <= "00001000";
        when "100" =>
          sel <= "00010000";
        when "101" =>
          sel <= "00100000";
        when "110" =>
          sel <= "01000000";
        when "111" =>
          sel <= "10000000";
        when others =>
          sel <= "00000000";
      end case;
    else
      sel <= "00000000";
    end if;    
  end process;
  
end Behavioral;

