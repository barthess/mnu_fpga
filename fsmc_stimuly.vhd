----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:35:35 09/16/2015 
-- Design Name: 
-- Module Name:    fsmc_testbench - Behavioral 
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

entity fsmc_stimuly is
    Port ( clk : out  STD_LOGIC; 
           A : out  STD_LOGIC_VECTOR (15 downto 0);
           D : inout  STD_LOGIC_VECTOR (15 downto 0);
           NCE : out  STD_LOGIC := '1';
           NWE : out  STD_LOGIC := '1';
           NOE : out  STD_LOGIC := '1';
           NBL : out  STD_LOGIC_VECTOR (1 downto 0));
end fsmc_stimuly;


architecture Beh of fsmc_stimuly is

constant T : TIME := 5.95 ns;
constant D_lat   : TIME := 3 ns; -- Data to FSMC_NEx low to Data valid
constant NOE_lat : TIME := 3 ns; -- FSMC_NEx low to FSMC_NOE low
constant A_lat   : TIME := 4.5 ns; -- FSMC_NEx low to FSMC_A valid
--constant clk_dT : TIME := 2.54 ns;
constant clk_dT : TIME := 3.8 ns;
signal shift : TIME := 59.5 ns;
signal clk_int : std_logic := '0';

begin
  
  NBL <= "00";
         
  A <= x"0000" after 1*T,
       x"0001" after 4*T,
       x"0002" after 7*T,
       -- read
       x"0000" after 1*T + shift,
       x"0001" after 5*T + shift,
       x"0002" after 9*T + shift;
       
  D <= x"EEEE" after D_lat + 1*T,
       x"5555" after D_lat + 4*T,
       x"1111" after D_lat + 7*T,
       -- read
       (others => 'Z') after 1*T + shift;

  NBL <= "00";
       
  NCE <= '1' after 0*T,
         '0' after 1*T,
         '1' after 3*T,
         '0' after 4*T,
         '1' after 6*T,
         '0' after 7*T,
         '1' after 9*T,
         -- read
         '1' after 0*T  + shift,
         '0' after 1*T  + shift,
         '1' after 4*T  + shift,
         '0' after 5*T  + shift,
         '1' after 8*T  + shift,
         '0' after 9*T  + shift,
         '1' after 12*T + shift;
 
  NWE <= '1' after 0*T,
         '0' after 1*T,
         '1' after 2*T,
         '0' after 4*T,
         '1' after 5*T,
         '0' after 7*T,
         '1' after 8*T;
         
  NOE <= '1' after 0*T  + shift,
         '0' after 1*T  + shift,
         '1' after 4*T  + shift,
         '0' after 5*T  + shift,
         '1' after 8*T  + shift,
         '0' after 9*T  + shift,
         '1' after 12*T + shift;


  clk_int <= not clk_int after clk_dT/2;
  clk <= clk_int;

end Beh;

