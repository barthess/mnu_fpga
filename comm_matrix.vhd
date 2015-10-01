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


entity comm_matrix is
  generic (
    AW : positive;  -- address width
    DW : positive   -- data width 
  );
  port(
    A : in  STD_LOGIC_VECTOR(2**AW-1 downto 0);
    i : in  STD_LOGIC_VECTOR(2**AW*DW-1 downto 0);
    o : out STD_LOGIC_VECTOR(2**AW*DW-1 downto 0)
  );
end demuxer;


architecture Behavioral of comm_matrix is
  constant count : positive := 2**AW; -- number of inputs
begin
  
  muxer_assign : for n in 0 to count-1 generate 
  begin
    muxer_array : entity work.muxer
    generic map (
      AW => AW,
      DW => DW
    )
    PORT MAP (
      i => i,
      o => o((n+1)*DW-1 downto n*DW),
      A => o((n+1)*AW-1 downto n*AW)
    );
  end generate;

end Behavioral;






