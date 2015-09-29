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
    DW : positive
  );
  Port (
    hclk : in  STD_LOGIC;

    pin_rdy : out std_logic;
    pin_dv  : in std_logic;
    
    fsmc_bram0_a   : in STD_LOGIC_VECTOR (BW-1 downto 0);
    fsmc_bram0_di  : in STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram0_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram0_en  : in STD_LOGIC;
    fsmc_bram0_we  : in std_logic_vector (1 downto 0);
    fsmc_bram0_clk : in std_logic;
    
    fsmc_bram1_a   : in STD_LOGIC_VECTOR (BW-1 downto 0);
    fsmc_bram1_di  : in STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram1_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram1_en  : in STD_LOGIC;
    fsmc_bram1_we  : in std_logic_vector (1 downto 0);
    fsmc_bram1_clk : in std_logic;
    
    fsmc_bram2_a   : in STD_LOGIC_VECTOR (BW-1 downto 0);
    fsmc_bram2_di  : in STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram2_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram2_en  : in STD_LOGIC;
    fsmc_bram2_we  : in std_logic_vector (1 downto 0);
    fsmc_bram2_clk : in std_logic;
    
    fsmc_bram3_a   : in STD_LOGIC_VECTOR (BW-1 downto 0);
    fsmc_bram3_di  : in STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram3_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram3_en  : in STD_LOGIC;
    fsmc_bram3_we  : in std_logic_vector (1 downto 0);
    fsmc_bram3_clk : in std_logic
  );
end mul_hive;



architecture Behavioral of mul_hive is

constant BW64 : positive := BW-2;

signal bram0_a  : STD_LOGIC_VECTOR (BW64-1 downto 0);
signal bram0_di : STD_LOGIC_VECTOR (63 downto 0);
signal bram0_do : STD_LOGIC_VECTOR (63 downto 0);
signal bram0_we : std_logic_vector (7 downto 0) := x"FF";
  
signal bram1_a  : STD_LOGIC_VECTOR (BW64-1 downto 0);
signal bram1_di : STD_LOGIC_VECTOR (63 downto 0);
signal bram1_do : STD_LOGIC_VECTOR (63 downto 0);
signal bram1_we : std_logic_vector (7 downto 0) := x"FF";
  
signal bram2_a  : STD_LOGIC_VECTOR (BW64-1 downto 0);
signal bram2_di : STD_LOGIC_VECTOR (63 downto 0);
signal bram2_do : STD_LOGIC_VECTOR (63 downto 0);
signal bram2_we : std_logic_vector (7 downto 0) := x"FF";
  
signal bram3_a  : STD_LOGIC_VECTOR (BW64-1 downto 0);
signal bram3_di : STD_LOGIC_VECTOR (63 downto 0);
signal bram3_do : STD_LOGIC_VECTOR (63 downto 0);
signal bram3_we : std_logic_vector (7 downto 0) := x"FF";
  
begin

  bram0 : entity work.bram 
  PORT MAP (
    addra => fsmc_bram0_a,
    dina  => fsmc_bram0_di,
    douta => fsmc_bram0_do,
    ena   => fsmc_bram0_en,
    wea   => fsmc_bram0_we,
    clka  => fsmc_bram0_clk,

    web   => bram0_we,
    addrb => bram0_a,
    dinb  => bram0_di,
    doutb => bram0_do,
    enb   => '1',
    clkb  => hclk
  );

  bram1 : entity work.bram 
  PORT MAP (
    addra => fsmc_bram1_a,
    dina  => fsmc_bram1_di,
    douta => fsmc_bram1_do,
    ena   => fsmc_bram1_en,
    wea   => fsmc_bram1_we,
    clka  => fsmc_bram1_clk,

    web   => bram1_we,
    addrb => bram1_a,
    dinb  => bram1_di,
    doutb => bram1_do,
    enb   => '1',
    clkb  => hclk
  );
  
  bram2 : entity work.bram 
  PORT MAP (
    addra => fsmc_bram2_a,
    dina  => fsmc_bram2_di,
    douta => fsmc_bram2_do,
    ena   => fsmc_bram2_en,
    wea   => fsmc_bram2_we,
    clka  => fsmc_bram2_clk,

    web   => bram2_we,
    addrb => bram2_a,
    dinb  => bram2_di,
    doutb => bram2_do,
    enb   => '1',
    clkb  => hclk
  );

  bram3 : entity work.bram 
  PORT MAP (
    addra => fsmc_bram3_a,
    dina  => fsmc_bram3_di,
    douta => fsmc_bram3_do,
    ena   => fsmc_bram3_en,
    wea   => fsmc_bram3_we,
    clka  => fsmc_bram3_clk,

    web   => bram3_we,
    addrb => bram3_a,
    dinb  => bram3_di,
    doutb => bram3_do,
    enb   => '1',
    clkb  => hclk
  );


  multiplier : entity work.multiplier
  Generic map (
    AW => BW64
  )
  Port map (
    clk => hclk,
    
    di_op0 => bram0_do,
    di_op1 => bram1_do,
    do_res => bram2_di,

    a_op0 => bram0_a,
    a_op1 => bram1_a,
    a_res => bram2_a,

    we_op0 => open,
    we_op1 => open,
    we_res => bram2_we,

    pin_rdy => pin_rdy,
    pin_dv => pin_dv
  );


end Behavioral;

