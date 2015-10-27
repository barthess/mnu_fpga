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

entity muxer is
  generic (
    AW  : positive; -- address width (select bits count)
    DW  : positive; -- data width 
    cnt : positive  -- actual inputs count
  );
  port(
    A : in  STD_LOGIC_VECTOR(AW-1     downto 0);
    i : in  STD_LOGIC_VECTOR(cnt*DW-1 downto 0);
    o : out STD_LOGIC_VECTOR(DW-1     downto 0)
  );
end muxer;


architecture Behavioral of muxer is
  signal addr : integer;
begin

  assert cnt <= 2**AW
    report "Not enough address bits"
    severity Failure;

  assert cnt*2 >= 2**AW+1
    report "Too many address bits"
    severity Failure;

  process(A) begin
    if (A >= cnt) then
      addr <= conv_integer(A) - cnt;
    else
      addr <= conv_integer(A);
    end if;
  end process;

  process(addr, i) begin
    o <= i((addr+1)*DW-1 downto addr*DW);
  end process;

end Behavioral;

