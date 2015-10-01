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


entity demuxer is
  generic (
    AW : positive;    -- address width
    DW : positive;    -- data width 
    count : positive  -- number of inputs
  );
  port(
    A : in  STD_LOGIC_VECTOR(AW-1 downto 0);
    i : in  STD_LOGIC_VECTOR(DW-1 downto 0);
    o : out STD_LOGIC_VECTOR(count*DW-1 downto 0)
  );
end demuxer;


architecture Behavioral of demuxer is

begin
  Этот демультиплексор не работает. Надо бы переписать
--  process(A) begin
--    if (0 = addr) then
--      o((n+1)*DW-1 downto n*DW) <= i;
--    else
--      o((n+1)*DW-1 downto n*DW) <= (others => '0');
--    end if;
--  end process;

--  array_assign : for n in 0 to count-1 generate 
--  begin
--    if (n = addr) then
--      o((n+1)*DW-1 downto n*DW) <= i;
--    else
--      o((n+1)*DW-1 downto n*DW) <= (others => '0');
--    end if;
--  end generate;

  o((conv_integer(A)+1)*DW-1 downto conv_integer(A)*DW) <= i;
  --o <= (((addr+1)*DW-1 downto addr*DW) => i, others => '0');
  --o <= (15 downto 0 => i, others => '0');
  --o <= (0 => '1', others => '0');

end Behavioral;

