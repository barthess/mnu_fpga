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
  Port (
    clk  : in  STD_LOGIC;
    bram_do : out std_logic_vector (63 downto 0) := (others => '0');
    bram_di : in std_logic_vector (63 downto 0);
    bram_a : out std_logic_vector (13 downto 0) := (others => '0');
    bram_we : out STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    -- debug
    dbg_led : out std_logic
  );
end multiplier_test;


architecture Behavioral of multiplier_test is

type state_t is (IDLE, LOAD1, LOAD2, MUL, RET, NOTIFY);
signal state : state_t := IDLE;

signal cycle : natural range 27 downto 0 := 0;      -- multiply cycle counter

signal in1_buf : std_logic_vector (63 downto 0) := (others => 'U');
signal in2_buf : std_logic_vector (63 downto 0) := (others => 'U');
signal result : std_logic_vector (63 downto 0) := (others => 'U');
signal ctrl_buf : std_logic := 'U';
signal mul_ce : std_logic := '0';

begin

  double_mul : entity work.double_mul
  PORT MAP (
    clk => clk,
    a => in1_buf,
    b => in2_buf,
    ce => mul_ce,
    result => result
  );

  process(clk) begin
    if rising_edge(clk) then
      case state is
      when IDLE =>
        bram_we <= x"00";
        mul_ce <= '0';
        bram_a <= (others => '0');
        ctrl_buf <= bram_di(0);
        dbg_led <= '0';
        if (ctrl_buf = '1') then
          dbg_led <= '1';
          bram_a  <= std_logic_vector(to_unsigned(4, 14));
          state <= LOAD1;
        end if;
        
      when LOAD1 =>
        in1_buf <= bram_di;
        bram_a <= std_logic_vector(to_unsigned(5, 14));
        state <= LOAD2;
        
      when LOAD2 =>
        in2_buf <= bram_di;
        state <= MUL;
        mul_ce <= '1';

      when MUL =>
        cycle <= cycle - 1;
        if (cycle = 0) then
          state <= RET;
          bram_we <= x"FF";
          bram_do <= result;
          bram_a <= std_logic_vector(to_unsigned(5, 14));
        end if;

      when RET =>
        state <= NOTIFY;
        mul_ce <= '0';
        bram_a <= std_logic_vector(to_unsigned(3, 14));
        bram_do <= std_logic_vector(to_unsigned(1, 64));
      
      when NOTIFY =>
        state <= IDLE;
        -- empty

      end case;
    end if;
  end process;
end Behavioral;





