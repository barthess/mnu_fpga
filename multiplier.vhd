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
    clk : in STD_LOGIC;
    ce  : in std_logic;
    rdy : out std_logic;
    
    -- opernads' sizes
    row : in  std_logic_vector (4 downto 0);
    col : in  std_logic_vector (4 downto 0);
    
    -- data buses
    op0_di : in  std_logic_vector (63 downto 0);
    op1_di : in  std_logic_vector (63 downto 0);
    res_do : out std_logic_vector (63 downto 0) := (others => 'X');

    -- address buses
    op0_a : out std_logic_vector (AW-1 downto 0);
    op1_a : out std_logic_vector (AW-1 downto 0);
    res_a : out std_logic_vector (AW-1 downto 0);
    
    -- result bram WE pin
    we : out std_logic
  );
end multiplier;





architecture Behavioral of multiplier is

type state_t is (
  IDLE,
  PRELOAD,  -- latency cycle for BRAM
  LOAD,     -- load next data portion to pipeline
  DRAIN
);

type out_state_t is (
  IDLE,
  DRAIN
);
  
signal state : state_t := IDLE;
signal out_state : out_state_t := IDLE;

signal mul_nd  : std_logic := '0';
signal mul_ce  : std_logic := '0';
signal mul_rdy : std_logic := '0';

signal total_steps : std_logic_vector (AW-1 downto 0) := (others => '0');
signal op0_ptr : std_logic_vector (AW-1 downto 0) := (others => '0');
signal op1_ptr : std_logic_vector (AW-1 downto 0) := (others => '0');
signal res_ptr : std_logic_vector (AW-1 downto 0) := (others => '0');

begin


  double_mul : entity work.double_mul
  PORT MAP (
    clk => clk,
    a => op0_di,
    b => op1_di,
    result => res_do,    
    ce => mul_ce,
    rdy => mul_rdy,
    operation_nd => mul_nd
  );

  op0_a <= op0_ptr;
  op1_a <= op1_ptr;
  res_a <= res_ptr;


  -- main state machine
  process(clk) begin
    if rising_edge(clk) then
      if (ce = '0') then
        state <= IDLE;
        mul_ce <= '0';
        rdy <= '0';
        op0_ptr <= (others => '0');
        op1_ptr <= (others => '0');
      else
        case state is
        
        when IDLE =>
          op0_ptr <= op0_ptr + 1;
          op1_ptr <= op1_ptr + 1;
          total_steps <= row * col;
          state <= PRELOAD;
          
        when PRELOAD =>
          op0_ptr <= op0_ptr + 1;
          op1_ptr <= op1_ptr + 1;
          mul_ce <= '1';
          mul_nd <= '1';
          state <= LOAD;
          
        when LOAD =>
          op0_ptr <= op0_ptr + 1;
          op1_ptr <= op1_ptr + 1;
          if (op0_ptr = total_steps + 2) then
            state <= DRAIN;
          end if;

        when DRAIN =>
          if (out_state = IDLE) then
            mul_ce <= '0';
            rdy <= '1';
            state <= IDLE;
          end if;
        end case;
        
      end if; -- ce
    end if;   -- clk
  end process;
  
  
  -- output draining state machine
  process(clk) begin
    if rising_edge(clk) then
      case out_state is
      
      when IDLE =>
        res_ptr <= (others => '0');
        if (state = IDLE) then
          out_state <= DRAIN;
          we <= '1';
        end if;

      when DRAIN =>
        if (mul_rdy = '1') then
          res_ptr <= res_ptr + 1;
        end if;
        if (res_ptr = total_steps + 1) then
          we <= '0';
          out_state <= IDLE;
        end if;
      end case;

    end if;
  end process;
end Behavioral;





