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

entity bram_pool is
  Generic (
    BW : positive;
    DW : positive
  );
  Port (
    fsmc_bram4_a   : in STD_LOGIC_VECTOR (BW-1 downto 0);
    fsmc_bram4_di  : in STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram4_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram4_en  : in STD_LOGIC;
    fsmc_bram4_we  : in std_logic_vector (1 downto 0);
    fsmc_bram4_clk : in std_logic;
    
    fsmc_bram5_a   : in STD_LOGIC_VECTOR (BW-1 downto 0);
    fsmc_bram5_di  : in STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram5_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram5_en  : in STD_LOGIC;
    fsmc_bram5_we  : in std_logic_vector (1 downto 0);
    fsmc_bram5_clk : in std_logic;
    
    fsmc_bram6_a   : in STD_LOGIC_VECTOR (BW-1 downto 0);
    fsmc_bram6_di  : in STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram6_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram6_en  : in STD_LOGIC;
    fsmc_bram6_we  : in std_logic_vector (1 downto 0);
    fsmc_bram6_clk : in std_logic;
    
    fsmc_bram7_a   : in STD_LOGIC_VECTOR (BW-1 downto 0);
    fsmc_bram7_di  : in STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram7_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_bram7_en  : in STD_LOGIC;
    fsmc_bram7_we  : in std_logic_vector (1 downto 0);
    fsmc_bram7_clk : in std_logic
  );
end bram_pool;



architecture Behavioral of bram_pool is

--constant BW64 : positive := BW-2;

--signal bram0_a  : STD_LOGIC_VECTOR (BW64-1 downto 0);
--signal bram0_di : STD_LOGIC_VECTOR (63 downto 0);
--signal bram0_do : STD_LOGIC_VECTOR (63 downto 0);
--signal bram0_we : std_logic_vector (7 downto 0) := x"00";
--  
--signal bram1_a  : STD_LOGIC_VECTOR (BW64-1 downto 0);
--signal bram1_di : STD_LOGIC_VECTOR (63 downto 0);
--signal bram1_do : STD_LOGIC_VECTOR (63 downto 0);
--signal bram1_we : std_logic_vector (7 downto 0) := x"00";
--  
--signal bram2_a  : STD_LOGIC_VECTOR (BW64-1 downto 0);
--signal bram2_di : STD_LOGIC_VECTOR (63 downto 0);
--signal bram2_do : STD_LOGIC_VECTOR (63 downto 0);
--signal bram2_we : std_logic_vector (7 downto 0) := x"00";
--  
--signal bram3_a  : STD_LOGIC_VECTOR (BW64-1 downto 0);
--signal bram3_di : STD_LOGIC_VECTOR (63 downto 0);
--signal bram3_do : STD_LOGIC_VECTOR (63 downto 0);
--signal bram3_we : std_logic_vector (7 downto 0) := x"00";
  
begin

  bram4 : entity work.bram 
  PORT MAP (
    addra => fsmc_bram4_a,
    dina  => fsmc_bram4_di,
    douta => fsmc_bram4_do,
    ena   => fsmc_bram4_en,
    wea   => fsmc_bram4_we,
    clka  => fsmc_bram4_clk,

    web   => (others => '0'),
    addrb => (others => '0'),
    dinb  => (others => '0'),
    doutb => open,
    enb   => '0',
    clkb  => fsmc_bram4_clk
  );

  bram5 : entity work.bram 
  PORT MAP (
    addra => fsmc_bram5_a,
    dina  => fsmc_bram5_di,
    douta => fsmc_bram5_do,
    ena   => fsmc_bram5_en,
    wea   => fsmc_bram5_we,
    clka  => fsmc_bram5_clk,

    web   => (others => '0'),
    addrb => (others => '0'),
    dinb  => (others => '0'),
    doutb => open,
    enb   => '0',
    clkb  => fsmc_bram5_clk
  );
  
  bram6 : entity work.bram 
  PORT MAP (
    addra => fsmc_bram6_a,
    dina  => fsmc_bram6_di,
    douta => fsmc_bram6_do,
    ena   => fsmc_bram6_en,
    wea   => fsmc_bram6_we,
    clka  => fsmc_bram6_clk,

    web   => (others => '0'),
    addrb => (others => '0'),
    dinb  => (others => '0'),
    doutb => open,
    enb   => '0',
    clkb  => fsmc_bram6_clk
  );

  bram7 : entity work.bram 
  PORT MAP (
    addra => fsmc_bram7_a,
    dina  => fsmc_bram7_di,
    douta => fsmc_bram7_do,
    ena   => fsmc_bram7_en,
    wea   => fsmc_bram7_we,
    clka  => fsmc_bram7_clk,

    web   => (others => '0'),
    addrb => (others => '0'),
    dinb  => (others => '0'),
    doutb => open,
    enb   => '0',
    clkb  => fsmc_bram7_clk
  );

end Behavioral;