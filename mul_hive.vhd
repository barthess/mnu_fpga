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

entity mul_hive is
  Generic (
    BW : positive;
    DW : positive;
    count : positive
  );
  Port (
    hclk : in STD_LOGIC;

    pin_rdy : out std_logic;
    pin_dv  : in std_logic;
    
    fsmc_bram_a   : in  STD_LOGIC_VECTOR (count*BW-1 downto 0);
    fsmc_bram_di  : in  STD_LOGIC_VECTOR (count*DW-1 downto 0);
    fsmc_bram_do  : out STD_LOGIC_VECTOR (count*DW-1 downto 0);
    fsmc_bram_en  : in  STD_LOGIC_vector (count-1    downto 0);
    fsmc_bram_we  : in  std_logic_vector (count*2-1  downto 0);
    fsmc_bram_clk : in  std_logic_vector (count-1    downto 0)
  );
end mul_hive;




architecture Behavioral of mul_hive is

constant BW64 : positive := BW-2;

signal bram_a  : STD_LOGIC_VECTOR (count*BW64-1 downto 0);
signal bram_di : STD_LOGIC_VECTOR (count*64-1   downto 0);
signal bram_do : STD_LOGIC_VECTOR (count*64-1   downto 0);
signal bram_we : std_logic_vector (count*8-1    downto 0);

begin

  bram_array : for i in count downto 1 generate 
  begin
    bram : entity work.bram 
    PORT MAP (
      addra => fsmc_bram_a   (i*BW-1 downto (i-1)*BW),
      dina  => fsmc_bram_di  (i*DW-1 downto (i-1)*DW),
      douta => fsmc_bram_do  (i*DW-1 downto (i-1)*DW),
      ena   => fsmc_bram_en  (i-1),
      wea   => fsmc_bram_we  (i*2-1 downto (i-1)*2),
      clka  => fsmc_bram_clk (i-1),

      web   => bram_we (i*8-1    downto (i-1)*8),
      addrb => bram_a  (i*BW64-1 downto (i-1)*BW64),
      dinb  => bram_di (i*64-1   downto (i-1)*64),
      doutb => bram_do (i*64-1   downto (i-1)*64),
      enb   => '1',
      clkb  => hclk
    );
  end generate;






  multiplier : entity work.multiplier
  Generic map (
    AW => BW64
  )
  Port map (
    clk => hclk,
    
    di_op0 => bram_do(63  downto 0),
    di_op1 => bram_do(127 downto 64),
    do_res => bram_di(191 downto 128),

    a_op0 => bram_a(BW64-1   downto 0),
    a_op1 => bram_a(BW64*2-1 downto BW64),
    a_res => bram_a(BW64*3-1 downto BW64*2),

    we_op0 => open,
    we_op1 => open,
    we_res => bram_we(7 downto 0),

    pin_rdy => pin_rdy,
    pin_dv => pin_dv
  );


end Behavioral;





