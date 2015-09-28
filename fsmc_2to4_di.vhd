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

entity fsmc_2to4_di is
  port(
    A   : in  STD_LOGIC_VECTOR(1 downto 0);
    --en  : in  std_logic;
    
    di0 : in STD_LOGIC_VECTOR(15 downto 0);
    di1 : in STD_LOGIC_VECTOR(15 downto 0);
    di2 : in STD_LOGIC_VECTOR(15 downto 0);
    di3 : in STD_LOGIC_VECTOR(15 downto 0);
    
    do : out STD_LOGIC_VECTOR(15 downto 0)
  );
end fsmc_2to4_di;

architecture Behavioral of fsmc_2to4_di is

begin
  do <= di0 when (A="00") else
        di1 when (A="01") else
        di2 when (A="10") else
        di3 when (A="11");

end Behavioral;

