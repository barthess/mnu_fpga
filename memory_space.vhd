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
    selfsmc : positive; -- 3
    cntfsmc : positive; -- 8
    
    AWCMD : positive; -- 12 (512 * 8)
    DWCMD : positive; -- 16
    selcmd : positive; -- 3
    cntcmd : positive; -- 8
    
    -- BRAMs for matrices have different widths of A and B ports
    AWMTRXA : positive; -- 12+sel
    DWMTRXA : positive; -- 16
    AWMTRXB : positive; -- 12-2
    DWMTRXB : positive; -- 64
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
    cmd_a   : in  STD_LOGIC_VECTOR (cntcmd*(AWCMD-selcmd)-1 downto 0);
    cmd_di  : in  STD_LOGIC_VECTOR (cntcmd*DWCMD-1 downto 0);
    cmd_do  : out STD_LOGIC_VECTOR (cntcmd*DWCMD-1 downto 0);
    cmd_en  : in  STD_LOGIC_vector (cntcmd-1       downto 0);
    cmd_we  : in  std_logic_vector (cntcmd-1       downto 0);
    cmd_clk : in  std_logic_vector (cntcmd-1       downto 0);
    
    -- wide bus part for matrices
    mtrx_a   : in  STD_LOGIC_VECTOR (cntmtrx*AWMTRXB-1 downto 0);
    mtrx_di  : in  STD_LOGIC_VECTOR (cntmtrx*DWMTRXB-1 downto 0);
    mtrx_do  : out STD_LOGIC_VECTOR (cntmtrx*DWMTRXB-1 downto 0);
    mtrx_en  : in  STD_LOGIC_vector (cntmtrx-1         downto 0);
    mtrx_we  : in  std_logic_vector (cntmtrx-1         downto 0);
    mtrx_clk : in  std_logic_vector (cntmtrx-1         downto 0)
  );
end memory_space;




architecture Behavioral of memory_space is
  
  signal wire_mtrx_a   : STD_LOGIC_VECTOR (cntmtrx*(AWMTRXA-selmtrx)-1 downto 0);
  signal wire_mtrx_di  : STD_LOGIC_VECTOR (cntmtrx*DWMTRXA-1 downto 0);
  signal wire_mtrx_do  : STD_LOGIC_VECTOR (cntmtrx*DWMTRXA-1 downto 0);
  signal wire_mtrx_en  : STD_LOGIC_vector (cntmtrx-1         downto 0);
  signal wire_mtrx_we  : std_logic_vector (cntmtrx-1         downto 0);
  signal wire_mtrx_clk : std_logic_vector (cntmtrx-1         downto 0);
  
  signal wire_cmd_a   : STD_LOGIC_VECTOR (AWCMD-1 downto 0);
  signal wire_cmd_di  : STD_LOGIC_VECTOR (DWCMD-1 downto 0);
  signal wire_cmd_do  : STD_LOGIC_VECTOR (DWCMD-1 downto 0);
  signal wire_cmd_en  : STD_LOGIC;
  signal wire_cmd_we  : std_logic_vector (0 downto 0);
  signal wire_cmd_clk : std_logic;

  signal wire_mtrxcmd_a   : STD_LOGIC_VECTOR (cntfsmc*AWCMD-1 downto 0);
  signal wire_mtrxcmd_di  : STD_LOGIC_VECTOR (cntfsmc*DWCMD-1 downto 0);
  signal wire_mtrxcmd_do  : STD_LOGIC_VECTOR (cntfsmc*DWCMD-1 downto 0);
  signal wire_mtrxcmd_en  : STD_LOGIC_vector (cntfsmc-1       downto 0);
  signal wire_mtrxcmd_we  : std_logic_vector (cntfsmc-1       downto 0);
  signal wire_mtrxcmd_clk : std_logic_vector (cntfsmc-1       downto 0);
  
begin

  
  cmd_space : entity work.cmd_space
  generic map (
    AW => AWCMD,
    DW => DWCMD,
    sel => selcmd,
    cnt => cntcmd
  )
  port map (
    -- stm32 part
    a   => wire_cmd_a,
    di  => wire_cmd_di,
    do  => wire_cmd_do,
    en  => wire_cmd_en,
    we  => wire_cmd_we,
    clk => wire_cmd_clk,
    asample => fsmc_asample,

    -- peripheral part
    cmd_a   => cmd_a,
    cmd_di  => cmd_di,
    cmd_do  => cmd_do,
    cmd_en  => cmd_en,
    cmd_we  => cmd_we,
    cmd_clk => cmd_clk
  );


  -- BRAM array for matrices
  mtrx_space : for n in 0 to cntmtrx-1 generate 
  begin
    bram : entity work.bram_mtrx
    PORT MAP (
      -- port A 16-bit width connected to aggregator
      addra => wire_mtrx_a   ((n+1)*(AWMTRXA-selmtrx)-1 downto n*(AWMTRXA-selmtrx)),
      dina  => wire_mtrx_di  ((n+1)*DWMTRXA-1           downto n*DWMTRXA),
      douta => wire_mtrx_do  ((n+1)*DWMTRXA-1           downto n*DWMTRXA),
      ena   => wire_mtrx_en  (n),
      wea   => wire_mtrx_we  (n downto n),
      clka  => wire_mtrx_clk (n),

      -- port B 64-bit width is connected to output ports of module
      addrb => mtrx_a  ((n+1)*AWMTRXB-1 downto n*AWMTRXB),
      dinb  => mtrx_di ((n+1)*DWMTRXB-1 downto n*DWMTRXB),
      doutb => mtrx_do ((n+1)*DWMTRXB-1 downto n*DWMTRXB),
      web   => mtrx_we (n downto n),
      enb   => mtrx_en (n),
      clkb  => mtrx_clk(n)
    );
  end generate;


  -- top level aggregator  
  wire_mtrxcmd_do  <= wire_mtrx_do  & wire_cmd_do;
  
  wire_mtrx_we  <= wire_mtrxcmd_we(cntfsmc-1 downto 1);
  wire_cmd_we   <= wire_mtrxcmd_we(0 downto 0);
  
  wire_mtrx_en  <= wire_mtrxcmd_en(cntfsmc-1 downto 1);
  wire_cmd_en   <= wire_mtrxcmd_en(0);
  
  wire_mtrx_clk <= wire_mtrxcmd_clk(cntfsmc-1 downto 1);
  wire_cmd_clk  <= wire_mtrxcmd_clk(0);
  
  wire_mtrx_a   <= wire_mtrxcmd_a(cntfsmc*AWCMD-1 downto AWCMD);
  wire_cmd_a    <= wire_mtrxcmd_a(AWCMD-1 downto 0);
  
  wire_mtrx_di  <= wire_mtrxcmd_di(cntfsmc*DWFSMC-1 downto DWFSMC);
  wire_cmd_di   <= wire_mtrxcmd_di(DWFSMC-1 downto 0);
  
  top_aggregator : entity work.bram_aggregator
    generic map (
      AW => AWFSMC, -- 15
      DW => DWFSMC, -- 16
      sel => selfsmc, -- 3
      slavecnt => cntfsmc -- 8
    )
    port map (
      A   => fsmc_a,
      DI  => fsmc_di,
      DO  => fsmc_do,
      EN  => fsmc_en,
      WE  => fsmc_we,
      CLK => fsmc_clk,
      ASAMPLE => fsmc_asample,
      
      slave_a   => wire_mtrxcmd_a,
      slave_di  => wire_mtrxcmd_do,
      slave_do  => wire_mtrxcmd_di,
      slave_en  => wire_mtrxcmd_en,
      slave_we  => wire_mtrxcmd_we,
      slave_clk => wire_mtrxcmd_clk
    );

end Behavioral;
