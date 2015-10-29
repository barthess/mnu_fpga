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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
    --dbg : out std_logic;
    
    clk : in STD_LOGIC;

    cmd_a   : out STD_LOGIC_VECTOR (cmdaw-1 downto 0) := (others => '0');
    cmd_di  : in  STD_LOGIC_VECTOR (cmddw-1 downto 0);
    cmd_do  : out STD_LOGIC_VECTOR (cmddw-1 downto 0) := (others => '0');
    cmd_ce  : out STD_LOGIC_vector (0 downto 0);
    cmd_we  : out std_logic_vector (0 downto 0);
    cmd_clk : out std_logic_vector (0 downto 0);

    mtrx_a   : out STD_LOGIC_VECTOR (mtrxcnt*mtrxaw-1 downto 0);
    mtrx_di  : in  STD_LOGIC_VECTOR (mtrxcnt*mtrxdw-1 downto 0);
    mtrx_do  : out STD_LOGIC_VECTOR (mtrxcnt*mtrxdw-1 downto 0);
    mtrx_ce  : out STD_LOGIC_vector (mtrxcnt-1        downto 0);
    mtrx_we  : out std_logic_vector (mtrxcnt-1        downto 0);
    mtrx_clk : out std_logic_vector (mtrxcnt-1        downto 0)
  );
end mul_hive;


architecture Behavioral of mul_hive is

signal operand_select : std_logic_vector (8 downto 0); -- spare & res[3] & op1[3] & op0[3]
-- stm32 assisted value for address busmatrix
-- (0 << op0) | (1 << op1) | (2 << res)
signal operand_addr_select : std_logic_vector (20 downto 0) := (others => '0');
signal mul_op  : STD_LOGIC_VECTOR (2*mtrxdw-1 downto 0);
signal mul_res : STD_LOGIC_VECTOR (mtrxdw-1 downto 0);
signal mul_rdy : STD_LOGIC := '0';
signal row : STD_LOGIC_VECTOR (4 downto 0);
signal col : STD_LOGIC_VECTOR (4 downto 0);
signal mul_ce : STD_LOGIC := '0';

signal res_a : STD_LOGIC_VECTOR (mtrxaw-1 downto 0);
signal op0_a : STD_LOGIC_VECTOR (mtrxaw-1 downto 0);
signal op1_a : STD_LOGIC_VECTOR (mtrxaw-1 downto 0);
signal bram_we : std_logic_vector(0 downto 0);

constant command_addr : std_logic_vector(cmdaw-1 downto 0) := std_logic_vector(to_unsigned(0, cmdaw));
constant size_addr    : std_logic_vector(cmdaw-1 downto 0) := std_logic_vector(to_unsigned(1, cmdaw));

type state_t is (IDLE, READ0, READ1, MUL);
signal state : state_t := IDLE;


begin

  di_mux : entity work.busmatrix
  generic map (
    AW => 3,
    DW => mtrxdw,
    icnt => mtrxcnt,
    ocnt => 2
  )
  PORT MAP (
    A  => operand_select(5 downto 0),
    di => mtrx_di,
    do => mul_op
  );


  a_demux : entity work.busmatrix
  generic map (
    AW => 3,
    DW => mtrxaw,
    icnt => 3,
    ocnt => mtrxcnt
  )
  PORT MAP (
    A  => operand_addr_select,
    di => res_a & op1_a & op0_a,
    do => mtrx_a
  );
  

  we_demux : entity work.demuxer
  generic map (
    AW => 3,
    DW => 1,
    cnt => mtrxcnt
  )
  PORT MAP (
    A  => operand_select(8 downto 6),
    di => bram_we,
    do => mtrx_we
  );


  multiplier : entity work.multiplier
  generic map (
    AW => 10
  )
  PORT MAP (
    clk => clk,
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



  -- hardwired lines 
  cmd_clk(0) <= clk;
  cmd_ce  <= "1";
  
  mtrx_clk <= (others => clk);
  mtrx_ce  <= "1111111";
  
  do_assign : for n in 0 to mtrxcnt-1 generate 
  begin
    mtrx_do((n+1)*64-1 downto n*64) <= mul_res;
  end generate;
  
  
  -- helper process. Converts 9 bits of operands numbers
  -- to 21 bits of address bus matrix
--  process(operand_select) 
--    variable op0 : integer;
--    variable op1 : integer;
--    variable res : integer;
--    variable tmp0 : std_logic_vector(20 downto 0);
--    variable tmp1 : std_logic_vector(20 downto 0);
--    variable tmp2 : std_logic_vector(20 downto 0);
--  begin
--    op0 := conv_integer(operand_select(2 downto 0));
--    op1 := conv_integer(operand_select(4 downto 2));
--    res := conv_integer(operand_select(6 downto 4));
--
--    tmp0 := std_logic_vector(shift_left(to_unsigned(0, 21), op0));
--    tmp1 := std_logic_vector(shift_left(to_unsigned(1, 21), op1));
--    tmp2 := std_logic_vector(shift_left(to_unsigned(2, 21), res));
--    
--    operand_addr_select <= tmp0 or tmp1 or tmp2;
--  end process;
  
  
  busmatrix_helper : entity work.busmatrix_helper
  generic map (
    AW => 3,
    icnt => 3,
    ocnt => 7
  )
  port map (
    i => operand_select,
    o => operand_addr_select
  );



--  process(clk) begin
--    if rising_edge(clk) then
--      cmd_a <= (others => '0');
--      dbg <= cmd_di(0);
--    end if;
--  end process;



  -- main process
  process(clk) begin
    if rising_edge(clk) then
      case state is
      
      when IDLE =>
        cmd_we <= "0";
        cmd_a <= command_addr;
        operand_select <= cmd_di(8 downto 0);
        if (cmd_di(15) = '1') then -- check operation flag
          cmd_a <= size_addr;
          state <= READ0;
        end if;
      
      when READ0 =>
        state <= READ1;
        cmd_a <= size_addr;
        
      when READ1 =>
        state <= MUL;
        row <= cmd_di(4  downto 0); -- LSB
        col <= cmd_di(12 downto 8); -- MSB
        mul_ce <= '1';
      
      when MUL =>
        if (mul_rdy = '1') then
          state  <= IDLE;
          mul_ce <= '0';
          cmd_a  <= command_addr;
          cmd_do <= (others => '0'); -- clear operation flag 
          cmd_we <= "1";
        end if;

      end case;
    end if;
  end process;
end Behavioral;
