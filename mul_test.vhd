----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:35:20 09/14/2015 
-- Design Name: 
-- Module Name:    mul_test - Behavioral 
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


entity multiplier_test is
  Generic (
    WA : positive := 16
  );
  Port (
    -- multiplication clock and ram clock
    clk : in  STD_LOGIC;
    clk_bram : out std_logic;
    
    di_op1  : in  std_logic_vector (63 downto 0);
    di_op2  : in  std_logic_vector (63 downto 0);
    do_res  : out std_logic_vector (63 downto 0) := (others => 'X');
    a_op1   : out std_logic_vector (WA-1 downto 0) := (others => '0');
    a_op2   : out std_logic_vector (WA-1 downto 0) := (others => '0');
    a_res   : out std_logic_vector (WA-1 downto 0) := (others => '0');

    we_op1  : out STD_LOGIC_VECTOR (7 DOWNTO 0) := x"00";
    we_op2  : out STD_LOGIC_VECTOR (7 DOWNTO 0) := x"00";
    we_res  : out STD_LOGIC_VECTOR (7 DOWNTO 0) := x"00";

    pin_rdy : out std_logic := '0';
    pin_dv  : in std_logic
  );
end multiplier_test;





architecture Behavioral of multiplier_test is

type state_t is (
  IDLE,
  LOAD0,  -- latency cycle for BRAM
  LOAD1,  -- data valid on inputs
  MUL,
  WAIT_DRAIN
);

type out_state_t is (
  IDLE,
  WAIT_FIRST,
  DRAIN
);
  
signal state : state_t := IDLE;
signal out_state : out_state_t := IDLE;

constant TOTAL_STEPS integer := 2048;
signal steps integer := TOTAL_STEPS;

constant start_address : std_logic_vector (WA-1 downto 0) := (others => '0');

signal addr_read  : std_logic_vector (WA-1 downto 0) := (others => '0');
signal addr_write : std_logic_vector (WA-1 downto 0) := (others => '0');
signal mul_nd  : std_logic := '0';
signal mul_ce  : std_logic := '0';
signal mul_rdy : std_logic := '0';

begin

  double_mul : entity work.double_mul
  PORT MAP (
    clk => clk,
    a => di_op1,
    b => di_op2,
    result => do_res,    
    ce => mul_ce,
    rdy => mul_rdy,
    operation_nd => mul_nd
  );

  a_op1 <= addr_read;
  a_op2 <= addr_read;
  a_res <= addr_write;


  -- read address increment
  process(clk) begin
    if rising_edge(clk) then
      case state is
      when LOAD0 or LOAD1 or MUL =>
        addr_read <= addr_read + 1;
      when others =>
        addr_read <= start_address;
      end case;
    end if;
  end process;



  -- write address increment
  process(clk) begin
    if rising_edge(clk) then
      case state is
      when LOAD0 or LOAD1 or MUL =>
        addr_read <= addr_read + 1;
      when others =>
        addr_read <= (others => '0');
      end case;
    end if;
  end process;

  








  -- main state machine
  process(clk) begin
    if rising_edge(clk) then
      case state is
      when IDLE =>
        we_res <= x"00";
        if (pin_dv = '1') then
          state <= LOAD0;
          addr_write <= (others => '0');
        end if;
        
      when LOAD0 =>
        state <= LOAD1;

      when LOAD1 =>
        state <= MUL;
        mul_nd <= '1';

      when MUL =>
        steps = steps - 1;
        if (steps = 0) then -- address wrapped around zero
          mul_nd = '0';
          if (mul_rdy = '0') then
            state <= WAIT_FIRST;
          else
            state <= DRAIN;
          end if
        end if;
      
      when WAIT_FIRST =>
        if (mul_rdy = '1') then
          state <= DRAIN;
        end if

      when DRAIN =>
        if (mul_rdy = '0') then
          state <= RET;
        end if;
        
      when RET =>
        pin_rdy <= '1';
        if (pin_dv = '0') then -- result downloaded by master
          state <= IDLE;
          pin_rdy <= '0';
        end if;
        
      end case;
    end if;
  end process;
end Behavioral;





