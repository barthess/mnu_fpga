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
  Generic (
    T : TIME := 17.85 ns
  );
  Port ( 
    clk : out  STD_LOGIC; 
    A : out  STD_LOGIC_VECTOR (15 downto 0);
    D : inout  STD_LOGIC_VECTOR (15 downto 0);
    NCE : out  STD_LOGIC := '1';
    NWE : out  STD_LOGIC := '1';
    NOE : out  STD_LOGIC := '1';
    NBL : out  STD_LOGIC_VECTOR (1 downto 0)
  );
end fsmc_stimuly;

architecture Beh of fsmc_stimuly is

constant D_lat : TIME := 3 * T;
constant wt : TIME := 6 * T;
constant rt : TIME := 7 * T;

--constant NOE_lat : TIME := 3 ns; -- FSMC_NEx low to FSMC_NOE low
--constant A_lat   : TIME := 4.5 ns; -- FSMC_NEx low to FSMC_A valid
--constant clk_dT : TIME := 2.54 ns;
--constant clk_dT : TIME := 3.8 ns;

signal clk_int : std_logic := '0';

begin
         
  A <= x"0000" after 0*wt,
       x"0002" after 1*wt,
       x"0000" after 2*wt + 0*rt,
       x"0002" after 2*wt + 1*rt;
       
  D <= x"1111" after D_lat + 0*T,
       x"2222" after D_lat + 1*T,
       (others => 'Z') after D_lat + 2*T,
       x"3333" after wt + D_lat + 0*T,
       x"4444" after wt + D_lat + 1*T,
       (others => 'Z') after wt + D_lat + 2*T;

  NCE <= '0' after 0*T,
         '1' after wt - 1*T,
         '0' after wt,
         '1' after 2*wt - 1*T,
         -- read back
         '0' after 2*wt + 0*T,
         '1' after 2*wt + rt - 1*T,
         '0' after 2*wt + rt,
         '1' after 2*wt + 2*rt;
 
  NWE <= '0' after 0*T,
         '1' after wt - 1*T,
         '0' after wt,
         '1' after 2*wt - 1*T;

  NOE <= '0' after 2*wt + 2.5*T,
         '1' after 2*wt + rt - 1*T,
         '0' after 2*wt + 1*rt + 2.5*T,
         '1' after 2*wt + 2*rt;


  clk_int <= not clk_int after T/2;
  clk <= clk_int;
  
  --NBL <= "00" after 0*T,
  
end Beh;

