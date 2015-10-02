----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:53:56 09/29/2015 
-- Design Name: 
-- Module Name:    mul_hive - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bram_mul_proxy is
  Generic (
    FSMC_AW : positive;
    FSMC_DW : positive; -- 16
    MUL_AW : positive;
    MUL_DW : positive;  -- 64
    count : positive
  );
  Port (
    hclk : in STD_LOGIC;

    pin_rdy : out std_logic;
    pin_dv  : in std_logic;
    
    -- FSMC interconnect part
    fsmc_a   : in  STD_LOGIC_VECTOR (count*FSMC_AW-1 downto 0);
    fsmc_di  : in  STD_LOGIC_VECTOR (count*FSMC_DW-1 downto 0);
    fsmc_do  : out STD_LOGIC_VECTOR (count*FSMC_DW-1 downto 0);
    fsmc_en  : in  STD_LOGIC_vector (count-1         downto 0);
    fsmc_we  : in  std_logic_vector (count*2-1       downto 0);
    fsmc_clk : in  std_logic_vector (count-1         downto 0);
    
    mul_a   : in  STD_LOGIC_VECTOR (count*MUL_AW-1  downto 0);
    mul_di  : in  STD_LOGIC_VECTOR (count*MUL_DW-1  downto 0);
    mul_do  : out STD_LOGIC_VECTOR (count*MUL_DW-1  downto 0);
    mul_en  : in  STD_LOGIC_vector (count-1         downto 0);
    mul_we  : in  std_logic_vector (count*8-1       downto 0);
    mul_clk : in  std_logic_vector (count-1         downto 0)
  );
end bram_mul_proxy;




architecture Behavioral of bram_mul_proxy is

begin

  bram_mul_proxy : for n in 0 to count-1 generate 
  begin
    bram : entity work.bram_mtrx
    PORT MAP (
      addra => fsmc_a   ((n+1)*FSMC_AW-1 downto n*FSMC_AW),
      dina  => fsmc_di  ((n+1)*FSMC_DW-1 downto n*FSMC_DW),
      douta => fsmc_do  ((n+1)*FSMC_DW-1 downto n*FSMC_DW),
      ena   => fsmc_en  (n),
      wea   => fsmc_we  ((n+1)*2-1 downto n*2),
      clka  => fsmc_clk (n),

      addrb => mul_a  ((n+1)*MUL_AW-1 downto n*MUL_AW),
      dinb  => mul_di ((n+1)*MUL_DW-1   downto n*MUL_DW),
      doutb => mul_do ((n+1)*MUL_DW-1   downto n*MUL_DW),
      web   => mul_we ((n+1)*8-1    downto n*8),
      enb   => mul_en (n),
      clkb  => mul_clk(n)
    );
  end generate;

end Behavioral;


