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


entity multiplier is
  Generic (
    AW : positive
  );
  Port (
    clk : in  STD_LOGIC;
    
    di_op0  : in  std_logic_vector (63 downto 0);
    di_op1  : in  std_logic_vector (63 downto 0);
    do_res  : out std_logic_vector (63 downto 0) := (others => 'X');

    a_op0   : out std_logic_vector (AW-1 downto 0) := (others => '0');
    a_op1   : out std_logic_vector (AW-1 downto 0) := (others => '0');
    a_res   : out std_logic_vector (AW-1 downto 0) := (others => '0');

    we_op0  : out STD_LOGIC_VECTOR (7 DOWNTO 0) := x"00";
    we_op1  : out STD_LOGIC_VECTOR (7 DOWNTO 0) := x"00";
    we_res  : out STD_LOGIC_VECTOR (7 DOWNTO 0) := x"00";

    pin_rdy : out std_logic := '0';
    pin_dv  : in std_logic
  );
end multiplier;





architecture Behavioral of multiplier is

type state_t is (
  IDLE,
  LOAD0,  -- latency cycle for BRAM
  LOAD1,  -- data valid on inputs
  MUL,
  WAIT_DRAIN,
  NOTIFY
);

type out_state_t is (
  OUT_IDLE,
  WAIT_FIRST,
  DRAIN
);
  
signal state : state_t := IDLE;
signal out_state : out_state_t := OUT_IDLE;

constant TOTAL_STEPS : integer := 2048;
signal steps : integer := TOTAL_STEPS;

constant start_address : std_logic_vector (AW-1 downto 0) := (others => '0');

signal addr_read  : std_logic_vector (AW-1 downto 0) := (others => '0');
signal addr_write : std_logic_vector (AW-1 downto 0) := (others => '0');
signal mul_nd  : std_logic := '0';
signal mul_ce  : std_logic := '0';
signal mul_rdy : std_logic := '0';

begin

  double_mul : entity work.double_mul
  PORT MAP (
    clk => clk,
    a => di_op0,
    b => di_op1,
    result => do_res,    
    ce => mul_ce,
    rdy => mul_rdy,
    operation_nd => mul_nd
  );

  a_op0 <= addr_read;
  a_op1 <= addr_read;
  a_res <= addr_write;

  -- output state machine
  process(clk) begin
    if rising_edge(clk) then
      case out_state is
      
      when OUT_IDLE =>
        we_res <= x"00";
        addr_write <= start_address;
        if (state = MUL) then
          out_state <= WAIT_FIRST;
        end if;
        
      when WAIT_FIRST =>
        if (mul_rdy = '1') then
          out_state <= DRAIN;
          addr_write <= addr_write + 1;
        end if;
        
      when DRAIN =>
        addr_write <= addr_write + 1;
        if (mul_rdy = '0') then
          out_state <= OUT_IDLE;
        end if;

      end case;
    end if;
  end process;


  -- main state machine
  process(clk) begin
    if rising_edge(clk) then
      case state is
      
      when IDLE =>
        mul_ce <= '0';
        addr_read <= start_address;
        if (pin_dv = '1') then
          addr_read <= addr_read + 1;
          state <= LOAD0;
        end if;
        
      when LOAD0 =>
        addr_read <= addr_read + 1;
        state <= LOAD1;
        
      when LOAD1 =>
        addr_read <= addr_read + 1;
        state <= MUL;
        mul_nd <= '1';
        mul_ce <= '1';

      when MUL =>
        addr_read <= addr_read + 1;
        steps <= steps - 1;
        if (steps = 0) then
          mul_nd <= '0';
          state <= WAIT_DRAIN;
        end if;
      
      when WAIT_DRAIN =>
        if (out_state = OUT_IDLE) then
          state <= NOTIFY;
        end if;

      -- hardware handshake with STM32
      when NOTIFY =>
        pin_rdy <= '1';
        if (pin_dv = '0') then -- result acquired by master
          state <= IDLE;
          pin_rdy <= '0';
        end if;

      end case;
    end if;
  end process;
end Behavioral;





