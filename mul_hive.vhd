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
    AW : positive;
    DW : positive; -- 64
    count : positive
  );
  Port (
    hclk : in STD_LOGIC;

    pin_err : out std_logic;
    pin_rdy : out std_logic;
    pin_dv  : in std_logic;
    
    bram_a   : out STD_LOGIC_VECTOR (count*AW-1 downto 0);
    bram_di  : in  STD_LOGIC_VECTOR (count*DW-1 downto 0);
    bram_do  : out STD_LOGIC_VECTOR (count*DW-1 downto 0);
    bram_en  : out STD_LOGIC_vector (count-1    downto 0);
    bram_we  : out std_logic_vector (count*8-1  downto 0);
    bram_clk : out std_logic_vector (count-1    downto 0)
  );
end mul_hive;


architecture Behavioral of mul_hive is

signal op_word : std_logic_vector (7 downto 0); -- spare & res & op1 & op0
signal mul_di : STD_LOGIC_VECTOR (2*DW-1 downto 0);
signal mul_res : STD_LOGIC_VECTOR (DW-1 downto 0);
signal a_res : STD_LOGIC_VECTOR (AW-1 downto 0);
signal a_op0 : STD_LOGIC_VECTOR (AW-1 downto 0);
signal a_op1 : STD_LOGIC_VECTOR (AW-1 downto 0);
signal a_spare : STD_LOGIC_VECTOR (AW-1 downto 0) := (others => '0');
signal we : std_logic_vector (7 downto 0);

begin


  di_mux : entity work.bus_matrix
  generic map (
    AW => 2,
    DW => DW,
    ocnt => 2
  )
  PORT MAP (
    A => op_word(3 downto 0),
    i => bram_di,
    o => mul_di
  );


  a_mux : entity work.bus_matrix
  generic map (
    AW => 2,
    DW => AW,
    ocnt => 4
  )
  PORT MAP (
    A => op_word,
    i => a_spare & a_res & a_op1 & a_op0,
    o => bram_a
  );
  
 
  we_demux : entity work.demuxer
  generic map (
    AW => 2,
    DW => 8,
    count => count
  )
  PORT MAP (
    A => op_word(5 downto 4),
    i => we,
    o => bram_we
  );

  
  
  

  multiplier : entity work.multiplier
  Generic map (
    AW => AW
  )
  Port map (
    clk => hclk,
    ce => '1',
    
    len => x"000F",
    height_op0 => x"000F",
    height_op1 => x"000F",
    
    op0 => mul_di(DW-1   downto 0),
    op1 => mul_di(2*DW-1 downto DW),
    res => mul_res,

    a_op0 => a_op0,
    a_op1 => a_op1,
    a_res => a_res,
    we => we,

    pin_rdy => pin_rdy,
    pin_dv => pin_dv
  );


end Behavioral;






