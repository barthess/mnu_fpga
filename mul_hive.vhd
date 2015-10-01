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

type a_array_t  is array(0 to count-1) of std_logic_vector(BW64-1 downto 0);
type di_array_t is array(0 to count-1) of std_logic_vector(63 downto 0);
type do_array_t is array(0 to count-1) of std_logic_vector(63 downto 0);
type we_array_t is array(0 to count-1) of std_logic_vector(7 downto 0);

signal a_array  : a_array_t;
signal di_array : di_array_t;
signal do_array : do_array_t;
signal we_array : we_array_t;

begin

  -- interconnect between multipliers and FSMC
  bram_bridge : for n in 0 to count-1 generate 
  begin
    bram : entity work.bram 
    PORT MAP (
      addra => fsmc_bram_a   ((n+1)*BW-1 downto n*BW),
      dina  => fsmc_bram_di  ((n+1)*DW-1 downto n*DW),
      douta => fsmc_bram_do  ((n+1)*DW-1 downto n*DW),
      ena   => fsmc_bram_en  (n),
      wea   => fsmc_bram_we  ((n+1)*2-1 downto n*2),
      clka  => fsmc_bram_clk (n),

      web   => we_array(n),
      addrb => a_array(n),
      dinb  => di_array(n),
      doutb => do_array(n),
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
    
    di_op0 => do_array(0),
    di_op1 => do_array(1),
    do_res => di_array(2),

    a_op0 => a_array(0),
    a_op1 => a_array(1),
    a_res => a_array(2),

    we_op0 => open,
    we_op1 => open,
    we_res => bram_we(7 downto 0),

    pin_rdy => pin_rdy,
    pin_dv => pin_dv
  );


end Behavioral;






