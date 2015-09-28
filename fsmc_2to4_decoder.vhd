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

entity fsmc_2to4_decoder is
  port(
    A  : in  STD_LOGIC_VECTOR(1 downto 0);
    ce : out STD_LOGIC_VECTOR(3 downto 0) := "0001"
  );
end fsmc_2to4_decoder;

architecture Behavioral of fsmc_2to4_decoder is

begin
  ce <= ("0001") when (A="00") else
        ("0010") when (A="01") else
        ("0100") when (A="10") else
        ("1000") ;
end Behavioral;

