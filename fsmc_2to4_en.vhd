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

entity fsmc_2to4_en is
  port(
    A   : in  STD_LOGIC_VECTOR(1 downto 0);
    en  : in  std_logic;
    sel : out STD_LOGIC_VECTOR(3 downto 0) := "0000"
  );
end fsmc_2to4_en;

architecture Behavioral of fsmc_2to4_en is

begin

  process(en, A) begin
    if (en = '1') then
      case A is
        when "00" =>
          sel <= "0001"; 
        when "01" =>
          sel <= "0010";
        when "10" =>
          sel <= "0100";
        when "11" =>
          sel <= "1000";
        when others =>
          sel <= "0000";
      end case;
    else
      sel <= "0000";
    end if;    
  end process;
  
end Behavioral;

