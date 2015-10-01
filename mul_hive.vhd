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

signal a_array  : std_logic_vector(count*BW64-1 downto 0);
signal di_array : std_logic_vector(count*64-1   downto 0);
signal do_array : std_logic_vector(count*64-1   downto 0);
signal we_array : std_logic_vector(count*8-1    downto 0);

signal d_op0 : std_logic_vector(63 downto 0);
signal d_op1 : std_logic_vector(63 downto 0);
signal d_res : std_logic_vector(63 downto 0);

signal a_op0 : std_logic_vector(BW64-1 downto 0);
signal a_op1 : std_logic_vector(BW64-1 downto 0);
signal a_res : std_logic_vector(BW64-1 downto 0);
signal a_spare : std_logic_vector(BW64-1 downto 0);

signal select_op0 : std_logic_vector(1 downto 0);
signal select_op1 : std_logic_vector(1 downto 0);
signal select_res : std_logic_vector(1 downto 0);

signal a_route_table : std_logic_vector(7 downto 0);

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

      addrb => a_array ((n+1)*BW64-1 downto n*BW64),
      dinb  => di_array((n+1)*64-1   downto n*64),
      doutb => do_array((n+1)*64-1   downto n*64),
      web   => we_array((n+1)*8-1    downto n*8),
      enb   => '1',
      clkb  => hclk
    );
  end generate;



  di_op0_mux : entity work.muxer
  generic map (
    AW => 2,
    DW => 64,
    count => 4
  )
  PORT MAP (
    A => select_op0,
    i => di_array,
    o => d_op0
  );

  di_op1_mux : entity work.muxer
  generic map (
    AW => 2,
    DW => 64,
    count => 4
  )
  PORT MAP (
    A => select_op1,
    i => di_array,
    o => d_op1
  );






  a_router : entity work.comm_matrix
  generic map (
    AW => 2,
    DW => BW64
  )
  PORT MAP (
    A => a_route_table,
    i => a_spare & a_res & a_op1 & a_op0,
    o => a_array
  );













  multiplier : entity work.multiplier
  Generic map (
    AW => BW64
  )
  Port map (
    clk => hclk,
    ce => '1',
    
    len => x"000F",
    height_op0 => x"000F",
    height_op1 => x"000F",
    
    di_op0 => d_op0,
    di_op1 => d_op1,
    do_res => d_res,

    a_op0 => a_op0,
    a_op1 => a_op1,
    a_res => a_res,

    pin_rdy => pin_rdy,
    pin_dv => pin_dv
  );


end Behavioral;






