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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-- helper for bus matrix with more outputs than inputs
entity busmatrix_helper is
  generic (
    AW   : positive; -- address width for multiplexers (select bits count)
    icnt : positive; -- input ports count
    ocnt : positive  -- output ports count
  );
  port(
    i : in  STD_LOGIC_VECTOR(icnt*AW-1 downto 0);
    o : out STD_LOGIC_VECTOR(ocnt*AW-1 downto 0)
  );
end busmatrix_helper;


architecture Behavioral of busmatrix_helper is
  
begin
  process(i) 
    variable tmp : std_logic_vector (ocnt*AW-1 downto 0);
    variable shift : integer;
  begin
    tmp := (others => '0');
    for n in 0 to icnt-1 loop 
      shift := AW * conv_integer(i ((n+1)*AW-1 downto n*AW));
      tmp := tmp or std_logic_vector(shift_left(to_unsigned(n, ocnt*AW), shift));
    end loop;
    o <= tmp;  
  end process;
end Behavioral;


