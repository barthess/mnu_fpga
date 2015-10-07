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

entity cmd_space is
  Generic (
    AW : positive; -- 12 (512 * 8)
    DW : positive; -- 16
    sel : positive; -- 3
    cnt : positive -- 8
  );
  Port (
    -- narrow bus part 
    a   : in  STD_LOGIC_VECTOR (AW-1 downto 0);
    di  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    en  : in  STD_LOGIC;
    we  : in  std_logic_vector (0 downto 0);
    clk : in  std_logic;
    asample : in STD_LOGIC;
    
    -- wide bus part for command space
    cmd_a   : in  STD_LOGIC_VECTOR (cnt*(AW-sel)-1  downto 0);
    cmd_di  : in  STD_LOGIC_VECTOR (cnt*DW-1        downto 0);
    cmd_do  : out STD_LOGIC_VECTOR (cnt*DW-1        downto 0);
    cmd_en  : in  STD_LOGIC_vector (cnt-1           downto 0);
    cmd_we  : in  std_logic_vector (cnt-1           downto 0);
    cmd_clk : in  std_logic_vector (cnt-1           downto 0)
  );
end cmd_space;




architecture Behavioral of cmd_space is
  
  signal wire_cmd_a   : STD_LOGIC_VECTOR (cnt*(AW-sel)-1 downto 0);
  signal wire_cmd_di  : STD_LOGIC_VECTOR (cnt*DW-1       downto 0);
  signal wire_cmd_do  : STD_LOGIC_VECTOR (cnt*DW-1       downto 0);
  signal wire_cmd_en  : STD_LOGIC_vector (cnt-1          downto 0);
  signal wire_cmd_we  : std_logic_vector (cnt-1          downto 0);
  signal wire_cmd_clk : std_logic_vector (cnt-1          downto 0);
  
begin

  -- BRAM array for commands
  cmd_space : for n in 0 to cnt-1 generate 
  begin
    bram : entity work.bram_cmd
    PORT MAP (
      -- port A 16-bit width connected to aggregator
      addra => wire_cmd_a   ((n+1)*(AW-sel)-1 downto n*(AW-sel)),
      dina  => wire_cmd_di  ((n+1)*DW-1       downto n*DW),
      douta => wire_cmd_do  ((n+1)*DW-1       downto n*DW),
      ena   => wire_cmd_en  (n),
      wea   => wire_cmd_we  (n downto n),
      clka  => wire_cmd_clk (n),

      -- port B 16-bit width is connected to output ports of module
      addrb => cmd_a  ((n+1)*(AW-sel)-1 downto n*(AW-sel)),
      dinb  => cmd_di ((n+1)*DW-1       downto n*DW),
      doutb => cmd_do ((n+1)*DW-1       downto n*DW),
      web   => cmd_we (n downto n),
      enb   => cmd_en (n),
      clkb  => cmd_clk(n)
    );
  end generate;


  -- aggregate all comand BRAMs into single block
  aggregator : entity work.bram_aggregator
    generic map (
      AW => AW, -- 12
      DW => DW, -- 16
      sel => sel, -- 3
      slavecnt => cnt -- 8
    )
    port map (
      A   => a,
      DI  => di,
      DO  => do,
      EN  => en,
      WE  => we,
      CLK => clk,
      ASAMPLE => asample,
      
      slave_a   => wire_cmd_a,
      slave_di  => wire_cmd_do,
      slave_do  => wire_cmd_di,
      slave_en  => wire_cmd_en,
      slave_we  => wire_cmd_we,
      slave_clk => wire_cmd_clk
    );

end Behavioral;


