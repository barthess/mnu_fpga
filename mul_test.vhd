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
  Port (
    clk  : in  STD_LOGIC;
    do   : out std_logic_vector (63 downto 0) := (others => '0');
    di   : in std_logic_vector (63 downto 0);
    addr : out std_logic_vector (11 downto 0) := (others => '0');
    en   : out STD_LOGIC := '0';
    we   : out STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00"
  );
end multiplier;


architecture Beh of multiplier is

type state_t is (IDLE, LOAD_A, LOAD_B, MUL, RET, NOTIFY);
signal state : state_t := IDLE;

signal cycle : natural range 27 downto 0 := 0;      -- multiply cycle counter

signal op_a_buf : std_logic_vector (63 downto 0) := (others => 'U');
signal op_b_buf : std_logic_vector (63 downto 0) := (others => 'U');
signal result   : std_logic_vector (63 downto 0) := (others => 'U');
signal ctrl_buf : std_logic_vector (63 downto 0) := (others => 'U');
signal mul_ce   : std_logic := '0';

begin

  double_mul : entity work.double_mul
  PORT MAP (
    a      => op_a_buf,
    b      => op_b_buf,
    clk    => clk,
    ce     => mul_ce,
    result => result
  );

  process(clk) begin
    if rising_edge(clk) then
      case state is
      when IDLE =>
        en <= '1';
        we <= x"00";
        mul_ce <= '0';
        addr <= (others => '0');
        ctrl_buf <= di;
        if (ctrl_buf(0) = '1') then
          addr  <= std_logic_vector(to_unsigned(4, 12));
          state <= LOAD_A;
        end if;
        
      when LOAD_A =>
        op_a_buf <= di;
        addr <= std_logic_vector(to_unsigned(5, 12));
        state <= LOAD_B;
        
      when LOAD_B =>
        op_a_buf <= di;
        state <= MUL;
        mul_ce <= '1';

      when MUL =>
        cycle <= cycle - 1;
        if (cycle = 0) then
          state <= RET;
          we    <= x"FF";
          do    <= result;
          addr  <= std_logic_vector(to_unsigned(5, 12));
        end if;

      when RET =>
        state <= NOTIFY;
        mul_ce <= '0';
        addr   <= std_logic_vector(to_unsigned(3, 12));
        do     <= std_logic_vector(to_unsigned(1, 64));
      
      when NOTIFY =>
        state <= IDLE;
        -- empty

      end case;
    end if;
      
  end process;
end Beh;





