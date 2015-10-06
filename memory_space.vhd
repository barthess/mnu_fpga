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

entity memory_space is
  Generic (
    AW : positive; -- 15 (4096 * 8)
    DW : positive; -- 16
    AWMUL : positive; -- AW-sel-2
    DWMUL : positive; -- 64
    sel : positive; -- 3
    count : positive -- 8
  );
  Port (
    --mmu_int : out std_logic;
    
    -- narrow bus part 
    fsmc_a   : in  STD_LOGIC_VECTOR (AW-1 downto 0);
    fsmc_di  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    fsmc_en  : in  STD_LOGIC;
    fsmc_we  : in  std_logic_vector (0 downto 0);
    fsmc_clk : in  std_logic;
    
    -- wide bus part
    mul_a   : in  STD_LOGIC_VECTOR (count*AWMUL-1 downto 0);
    mul_di  : in  STD_LOGIC_VECTOR (count*DWMUL-1 downto 0);
    mul_do  : out STD_LOGIC_VECTOR (count*DWMUL-1 downto 0);
    mul_en  : in  STD_LOGIC_vector (count-1       downto 0);
    mul_we  : in  std_logic_vector (count-1       downto 0);
    mul_clk : in  std_logic_vector (count-1       downto 0)
  );
end memory_space;




architecture Behavioral of memory_space is

  signal wire_fsmc_a   : STD_LOGIC_VECTOR (count*(AW-sel)-1 downto 0);
  signal wire_fsmc_di  : STD_LOGIC_VECTOR (count*DW-1 downto 0);
  signal wire_fsmc_do  : STD_LOGIC_VECTOR (count*DW-1 downto 0);
  signal wire_fsmc_en  : STD_LOGIC_vector (count-1    downto 0);
  signal wire_fsmc_we  : std_logic_vector (count-1    downto 0);
  signal wire_fsmc_clk : std_logic_vector (count-1    downto 0);
  
begin

  -- BRAM aggregator
  bram_aggregator : entity work.bram_aggregator
    generic map (
      AW => 15, -- input address width
      DW => 16, -- data witdth
      sel => 3, -- number bits used for slave addressing
      slavecnt => 8 -- number of actually realized outputs
    )
    port map (
      --mmu_int => mmu_int,
      
      A   => fsmc_a,
      DI  => fsmc_di,
      DO  => fsmc_do,
      EN  => fsmc_en,
      WE  => fsmc_we,
      CLK => fsmc_clk,
      
      slave_a   => wire_fsmc_a,
      slave_di  => wire_fsmc_di,
      slave_do  => wire_fsmc_do,
      slave_en  => wire_fsmc_en,
      slave_we  => wire_fsmc_we,
      slave_clk => wire_fsmc_clk
    );

  -- BRAM array
  memory_space : for n in 0 to count-1 generate 
  begin
    bram : entity work.bram_mtrx
    PORT MAP (
      -- port A connected to FSMC using following chain: FSMC <= aggregator <= bramA
      addra => wire_fsmc_a   ((n+1)*(AW-sel)-1 downto n*(AW-sel)),
      dina  => wire_fsmc_do  ((n+1)*DW-1 downto n*DW),
      douta => wire_fsmc_di  ((n+1)*DW-1 downto n*DW),
      ena   => wire_fsmc_en  (n),
      wea   => wire_fsmc_we  (n downto n),
      clka  => wire_fsmc_clk (n),

      -- port B is empty and ready to connect to a multiplier
      addrb => mul_a  ((n+1)*AWMUL-1 downto n*AWMUL),
      dinb  => mul_di ((n+1)*DWMUL-1 downto n*DWMUL),
      doutb => mul_do ((n+1)*DWMUL-1 downto n*DWMUL),
      web   => mul_we (n downto n),
      enb   => mul_en (n),
      clkb  => mul_clk(n)
    );
  end generate;

end Behavioral;


