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

entity fsmc_3to8_di is
  port(
    A  : in  STD_LOGIC_VECTOR(2 downto 0);
    
    i0 : in STD_LOGIC_VECTOR(15 downto 0);
    i1 : in STD_LOGIC_VECTOR(15 downto 0);
    i2 : in STD_LOGIC_VECTOR(15 downto 0);
    i3 : in STD_LOGIC_VECTOR(15 downto 0);
    i4 : in STD_LOGIC_VECTOR(15 downto 0);
    i5 : in STD_LOGIC_VECTOR(15 downto 0);
    i6 : in STD_LOGIC_VECTOR(15 downto 0);
    i7 : in STD_LOGIC_VECTOR(15 downto 0);
    
    o  : out STD_LOGIC_VECTOR(15 downto 0)
  );
end fsmc_3to8_di;

architecture Behavioral of fsmc_3to8_di is

begin
  o <= i0 when (A="000") else
       i1 when (A="001") else
       i2 when (A="010") else
       i3 when (A="011") else
       i4 when (A="100") else
       i5 when (A="101") else
       i6 when (A="110") else
       i7;

end Behavioral;

