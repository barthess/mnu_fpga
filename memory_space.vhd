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
    AWFSMC : positive; -- 15 (4096 * 8)
    DWFSMC : positive; -- 16
    
    AWCMD : positive; -- 12 (512 * 8)
    DWCMD : positive; -- 16
    selcmd : positive; -- 3
    cntcmd : positive; -- 8
    
    AWMTRX : positive; -- AW-sel-2
    DWMTRX : positive; -- 64
    selmtrx : positive; -- 3
    cntmtrx : positive -- 7
  );
  Port (
    -- narrow bus part 
    fsmc_a   : in  STD_LOGIC_VECTOR (AWFSMC-1 downto 0);
    fsmc_di  : in  STD_LOGIC_VECTOR (DWFSMC-1 downto 0);
    fsmc_do  : out STD_LOGIC_VECTOR (DWFSMC-1 downto 0);
    fsmc_en  : in  STD_LOGIC;
    fsmc_we  : in  std_logic_vector (0 downto 0);
    fsmc_clk : in  std_logic;
    fsmc_asample : in STD_LOGIC;
    
    -- wide bus part for command space
    cmd_a   : in  STD_LOGIC_VECTOR (cntcmd*AWCMD-1 downto 0);
    cmd_di  : in  STD_LOGIC_VECTOR (cntcmd*DWCMD-1 downto 0);
    cmd_do  : out STD_LOGIC_VECTOR (cntcmd*DWCMD-1 downto 0);
    cmd_en  : in  STD_LOGIC_vector (cntcmd-1       downto 0);
    cmd_we  : in  std_logic_vector (cntcmd-1       downto 0);
    cmd_clk : in  std_logic_vector (cntcmd-1       downto 0)
    
    -- wide bus part for matrices
    mtrx_a   : in  STD_LOGIC_VECTOR (cntmtrx*AWMTRX-1 downto 0);
    mtrx_di  : in  STD_LOGIC_VECTOR (cntmtrx*DWMTRX-1 downto 0);
    mtrx_do  : out STD_LOGIC_VECTOR (cntmtrx*DWMTRX-1 downto 0);
    mtrx_en  : in  STD_LOGIC_vector (cntmtrx-1        downto 0);
    mtrx_we  : in  std_logic_vector (cntmtrx-1        downto 0);
    mtrx_clk : in  std_logic_vector (cntmtrx-1        downto 0)
  );
end memory_space;




architecture Behavioral of memory_space is

  signal wire_fsmc_a   : STD_LOGIC_VECTOR (count*(AW-sel)-1 downto 0);
  signal wire_fsmc_di  : STD_LOGIC_VECTOR (count*DW-1 downto 0);
  signal wire_fsmc_do  : STD_LOGIC_VECTOR (count*DW-1 downto 0);
  signal wire_fsmc_en  : STD_LOGIC_vector (count-1    downto 0);
  signal wire_fsmc_we  : std_logic_vector (count-1    downto 0);
  signal wire_fsmc_clk : std_logic_vector (count-1    downto 0);
  
  signal wire_mtrx_a   : STD_LOGIC_VECTOR (count*(AW-sel)-1 downto 0);
  signal wire_mtrx_di  : STD_LOGIC_VECTOR (count*DW-1 downto 0);
  signal wire_mtrx_do  : STD_LOGIC_VECTOR (count*DW-1 downto 0);
  signal wire_mtrx_en  : STD_LOGIC_vector (count-1    downto 0);
  signal wire_mtrx_we  : std_logic_vector (count-1    downto 0);
  signal wire_mtrx_clk : std_logic_vector (count-1    downto 0);
  
  signal wire_cmd_a   : STD_LOGIC_VECTOR (count*(AW-sel)-1 downto 0);
  signal wire_cmd_di  : STD_LOGIC_VECTOR (count*DW-1 downto 0);
  signal wire_cmd_do  : STD_LOGIC_VECTOR (count*DW-1 downto 0);
  signal wire_cmd_en  : STD_LOGIC_vector (count-1    downto 0);
  signal wire_cmd_we  : std_logic_vector (count-1    downto 0);
  signal wire_cmd_clk : std_logic_vector (count-1    downto 0);

  signal aggr_cmd_a   : STD_LOGIC_VECTOR (count*(AW-sel)-1 downto 0);
  signal aggr_cmd_di  : STD_LOGIC_VECTOR (count*DW-1 downto 0);
  signal aggr_cmd_do  : STD_LOGIC_VECTOR (count*DW-1 downto 0);
  signal aggr_cmd_en  : STD_LOGIC_vector (count-1    downto 0);
  signal aggr_cmd_we  : std_logic_vector (count-1    downto 0);
  signal aggr_cmd_clk : std_logic_vector (count-1    downto 0);
  
begin

  -- BRAM array for matrices
  mtrx_space : for n in 0 to cntmtrx-1 generate 
  begin
    bram : entity work.bram_mtrx
    PORT MAP (
      -- port A connected to aggregator
      addra => wire_mtrx_a   ((n+1)*(12)-1  downto n*(12)),
      dina  => wire_mtrx_do  ((n+1)*DWFSMC-1        downto n*DWFSMC),
      douta => wire_mtrx_di  ((n+1)*DWFSMC-1        downto n*DWFSMC),
      ena   => wire_mtrx_en  (n),
      wea   => wire_mtrx_we  (n downto n),
      clka  => wire_mtrx_clk (n),

      -- port B is connected to output ports of module
      addrb => mtrx_a  ((n+1)*AWMTRX-1 downto n*AWMTRX),
      dinb  => mtrx_di ((n+1)*DWMTRX-1 downto n*DWMTRX),
      doutb => mtrx_do ((n+1)*DWMTRX-1 downto n*DWMTRX),
      web   => mtrx_we (n downto n),
      enb   => mtrx_en (n),
      clkb  => mtrx_clk(n)
    );
  end generate;

  -- BRAM array for commands
  cmd_space : for n in 0 to cntcmd-1 generate 
  begin
    bram : entity work.bram_cmd
    PORT MAP (
      -- port A connected to aggregator
      addra => wire_cmd_a   ((n+1)*(AWCMD-selcmd)-1 downto n*(AWCMD-selcmd)),
      dina  => wire_cmd_do  ((n+1)*DWCMD-1          downto n*DWCMD),
      douta => wire_cmd_di  ((n+1)*DWCMD-1          downto n*DWCMD),
      ena   => wire_cmd_en  (n),
      wea   => wire_cmd_we  (n downto n),
      clka  => wire_cmd_clk (n),

      -- port B is connected to output ports of module
      addrb => cmd_a  ((n+1)*(AWCMD-selcmd)-1 downto n*AWCMD),
      dinb  => cmd_di ((n+1)*DWCMD-1          downto n*DWCMD),
      doutb => cmd_do ((n+1)*DWCMD-1          downto n*DWCMD),
      web   => cmd_we (n downto n),
      enb   => cmd_en (n),
      clkb  => cmd_clk(n)
    );
  end generate;
  

  -- now aggregate all comand BRAMs into single block with
  -- same interface like single matrix BRAM 
  cmd_aggregator : entity work.bram_aggregator
    generic map (
      AW => AWCMD, -- 12
      DW => DWCMD, -- 16
      sel => selcmd, -- 3
      slavecnt => cntcmd -- 8
    )
    port map (
      A   => aggr_cmd_a,
      DI  => aggr_cmd_di,
      DO  => aggr_cmd_do,
      EN  => aggr_cmd_en,
      WE  => aggr_cmd_we,
      CLK => aggr_cmd_clk,
      ASAMPLE => fsmc_asample,
      
      slave_a   => wire_cmd_a,
      slave_di  => wire_cmd_di,
      slave_do  => wire_cmd_do,
      slave_en  => wire_cmd_en,
      slave_we  => wire_cmd_we,
      slave_clk => wire_cmd_clk
    );



  -- top level aggregator
  top_aggregator : entity work.bram_aggregator
    generic map (
      AW => AWFSMC, -- 15
      DW => DWFSMC, -- 16
      sel => sel, -- 3
      slavecnt => count -- 8
    )
    port map (
      A   => fsmc_a,
      DI  => fsmc_di,
      DO  => fsmc_do,
      EN  => fsmc_en,
      WE  => fsmc_we,
      CLK => fsmc_clk,
      ASAMPLE => fsmc_asample,
      
      slave_a   => wire_mtrx_a   & aggr_cmd_a,
      slave_di  => wire_mtrx_di  & aggr_cmd_di,
      slave_do  => wire_mtrx_do  & aggr_cmd_do,
      slave_en  => wire_mtrx_en  & aggr_cmd_en,
      slave_we  => wire_mtrx_we  & aggr_cmd_we,
      slave_clk => wire_mtrx_clk & aggr_cmd_clk
    );


  
  
end Behavioral;


