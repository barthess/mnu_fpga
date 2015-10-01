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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsmc_di_mux is
  generic (
    DW : positive;
    count : positive
  );
  port(
    A : in  STD_LOGIC_VECTOR(2 downto 0);
    i : in  STD_LOGIC_VECTOR(count*DW-1 downto 0);
    o : out STD_LOGIC_VECTOR(DW-1 downto 0)
  );
end fsmc_di_mux;


architecture Behavioral of fsmc_di_mux is

type proxy_t is array(0 to count-1) of std_logic_vector(DW-1 downto 0);
signal proxy : proxy_t;

begin

  array_assign : for n in 0 to count-1 generate 
  begin
    proxy(n) <= i((n+1)*DW-1 downto n*DW);
  end generate;
  
  o <= proxy(conv_integer(A));

end Behavioral;











