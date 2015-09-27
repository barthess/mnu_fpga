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
    bram_a : out std_logic_vector (1 downto 0) := (others => '0');
    bram_we : out STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00"
  );
end multiplier_test;


architecture Behavioral of multiplier_test is

type state_t is (IDLE, LOAD0, LOAD1, LOAD2, MUL, RET, NOTIFY);
signal state : state_t := IDLE;

--constant MUL_CYCLE : natural := 9;
--signal cycle : natural range 0 to MUL_CYCLE;
--signal cycle : std_logic_vector (7 downto 0) := x"00";
--signal dbg_cnt : std_logic_vector (63 downto 0) := (others => '0');

constant ctrl_addr : std_logic_vector (1 downto 0) := std_logic_vector(to_unsigned(0, 2));
constant in1_addr : std_logic_vector (1 downto 0) := std_logic_vector(to_unsigned(1, 2));
constant in2_addr : std_logic_vector (1 downto 0) := std_logic_vector(to_unsigned(2, 2));
constant result_addr : std_logic_vector (1 downto 0) := std_logic_vector(to_unsigned(3, 2));

signal in1_buf : std_logic_vector (63 downto 0) := (others => 'U');
signal in2_buf : std_logic_vector (63 downto 0) := (others => 'U');
signal result : std_logic_vector (63 downto 0) := (others => 'U');
signal result_buf : std_logic_vector (63 downto 0) := (others => 'U');
signal mul_new_data : std_logic := '0';
signal mul_rdy : std_logic := '0';

begin

  double_mul : entity work.double_mul
  PORT MAP (
    clk => clk,
    a => in1_buf,
    b => in2_buf,
    result => result,
    
    rdy => mul_rdy,
    operation_nd => mul_new_data
  );

  process(clk) begin
    if rising_edge(clk) then
      case state is
      
      when IDLE =>
        --cycle <= bram_di(7 downto 0);
        --dbg_cnt <= (others => '0');
        bram_we <= x"00";
        if (bram_di > x"0000_0000_0000_0000") then
          state <= LOAD0;
          bram_a <= in1_addr;
        end if;
        
      when LOAD0 =>
        state <= LOAD1;
        bram_a <= in2_addr;

      when LOAD1 =>
        state <= LOAD2;
        in1_buf <= bram_di;

      when LOAD2 =>
        state <= MUL;
        in2_buf <= bram_di;
        mul_new_data <= '1';
        
      when MUL =>
        mul_new_data <= '0';
        result_buf <= result;
        if (mul_rdy = '1') then
          bram_we <= x"FF";
          bram_do <= result_buf;
          bram_a  <= result_addr;
          state   <= RET;
        end if;
        
      when RET =>
        state <= NOTIFY;
        
      when NOTIFY =>
        bram_we <= x"FF";
        bram_do <= (others => '0');
        bram_a <= ctrl_addr;
        state <= IDLE;
        
      end case;
    end if;
  end process;
end Behavioral;





