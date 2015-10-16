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
    cmdaw  : positive; -- 9
    cmddw  : positive; -- 16
    mtrxaw : positive; -- 12
    mtrxdw : positive; -- 64
    mtrxcnt: positive  -- 7 total regions for matrices
  );
  Port (
    hclk : in STD_LOGIC;

    cmd_a   : out STD_LOGIC_VECTOR (cmdaw-1 downto 0);
    cmd_di  : in  STD_LOGIC_VECTOR (cmddw-1 downto 0);
    cmd_do  : out STD_LOGIC_VECTOR (cmddw-1 downto 0);
    cmd_en  : out STD_LOGIC_vector (0 downto 0);
    cmd_we  : out std_logic_vector (0 downto 0);
    cmd_clk : out std_logic_vector (0 downto 0);

    mtrx_a   : out STD_LOGIC_VECTOR (mtrxcnt*mtrxaw-1 downto 0);
    mtrx_di  : in  STD_LOGIC_VECTOR (mtrxcnt*mtrxdw-1 downto 0);
    mtrx_do  : out STD_LOGIC_VECTOR (mtrxcnt*mtrxdw-1 downto 0);
    mtrx_en  : out STD_LOGIC_vector (mtrxcnt-1        downto 0);
    mtrx_we  : out std_logic_vector (mtrxcnt-1        downto 0);
    mtrx_clk : out std_logic_vector (mtrxcnt-1        downto 0)
  );
end mul_hive;


architecture Behavioral of mul_hive is

signal operand_select : std_logic_vector (8 downto 0); -- spare & res[3] & op1[3] & op0[3]
signal mul_op  : STD_LOGIC_VECTOR (2*mtrxdw-1 downto 0);
signal mul_res : STD_LOGIC_VECTOR (mtrxdw-1 downto 0);
signal mul_rdy : STD_LOGIC := '0';
signal row : STD_LOGIC_VECTOR (7 downto 0);
signal col : STD_LOGIC_VECTOR (7 downto 0);
signal mul_ce : STD_LOGIC := '0';

signal res_a : STD_LOGIC_VECTOR (mtrxaw-1 downto 0);
signal op0_a : STD_LOGIC_VECTOR (mtrxaw-1 downto 0);
signal op1_a : STD_LOGIC_VECTOR (mtrxaw-1 downto 0);
signal bram_we : std_logic_vector(0 downto 0);

constant command_addr : std_logic_vector(cmdaw-1 downto 0) := std_logic_vector(to_unsigned(0, cmdaw));
constant size_addr : std_logic_vector(cmdaw-1 downto 0) := std_logic_vector(to_unsigned(1, cmdaw));

type state_t is (IDLE, READ0, READ1, MUL);
signal state : state_t := IDLE;


begin

  di_mux : entity work.bus_matrix
  generic map (
    AW => 3,
    DW => mtrxdw,
    icnt => mtrxcnt,
    ocnt => 2
  )
  PORT MAP (
    A => operand_select(5 downto 0),
    i => mtrx_di,
    o => mul_op
  );


  a_mux : entity work.bus_matrix
  generic map (
    AW => 3,
    DW => mtrxaw,
    icnt => 3,
    ocnt => mtrxcnt
  )
  PORT MAP (
    A => operand_select,
    i => res_a & op1_a & op0_a,
    o => mtrx_a
  );
  

  we_demux : entity work.demuxer
  generic map (
    AW => 3,
    DW => 1,
    count => mtrxcnt
  )
  PORT MAP (
    A => operand_select(8 downto 6),
    i => bram_we,
    o => mtrx_we
  );


  multiplier : entity work.multiplier
  generic map (
    AW => 12
  )
  PORT MAP (
    clk => hclk,
    ce  => mul_ce,
    rdy => mul_rdy,
  
    row => row,
    col => col,
  
    op0_di => mul_op(63 downto 0),
    op1_di => mul_op(127 downto 64),
    res_do => mul_res,
    
    op0_a => op0_a,
    op1_a => op1_a,
    res_a => res_a,

    we => bram_we(0)
  );


  process(hclk) begin
    if rising_edge(hclk) then
      case state is
      
      when IDLE =>
        cmd_a <= command_addr;
        operand_select <= cmd_di(8 downto 0);
        if (cmd_di(8) = '1') then -- check operation flag
          cmd_a <= size_addr;
          state <= READ0;
        end if;
      
      when READ0 =>
        state <= READ1;
        cmd_a <= size_addr;
        
      when READ1 =>
        state <= MUL;
        row <= cmd_di(7  downto 0);
        col <= cmd_di(15 downto 8);
        mul_ce <= '1';
      
      when MUL =>
        if (mul_rdy = '1') then
          state  <= IDLE;
          mul_ce <= '0';
          cmd_a  <= command_addr;
          cmd_do <= (others => '0'); -- clear operation flag 
        end if;
      
      end case;
    end if;
  end process;
end Behavioral;
