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
constant D_lat : TIME := 3 ns;
constant clk_dT : TIME := 2.54 ns;
signal clk_int : std_logic := '0';

begin
  A <= x"0000" after 1*T,
       x"0001" after 4*T,
       x"0002" after 7*T;

  D <= x"EEEE" after D_lat + 1*T,
       x"5555" after D_lat + 4*T,
       x"1111" after D_lat + 7*T;
  
  NCE <= '1',
         '0' after T,
         '1' after 3*T,
         '0' after 4*T,
         '1' after 6*T,
         '0' after 7*T,
         '1' after 9*T;

  NBL <= "00";
         
  NWE <= '1',
         '0' after T,
         '1' after 2*T,
         '0' after 4*T,
         '1' after 5*T,
         '0' after 7*T,
         '1' after 8*T;

  
--  A <= x"0000",
--       x"ABCD" after 3*T,
--       x"EFFA" after 6*T;
--
--  NCE <= '1',
--         '0' after T,
--         '1' after 3*T;
--  
--  NOE <= '1',
--         '0' after T,
--         '1' after 2*T;

  clk_int <= not clk_int after clk_dT/2;
  clk <= clk_int;
  
end Beh;

