----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:55:46 10/07/2015 
-- Design Name: 
-- Module Name:    pwm_wrapper - Behavioral 
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwm_wrapper is
  generic (
    CLKIN_FREQ : integer     -- in MHz
  );
  port (
    clk  : in  std_logic;
    leds : out STD_LOGIC_VECTOR (5 downto 0);
    
    a   : out STD_LOGIC_VECTOR (8 downto 0);
    di  : in  STD_LOGIC_VECTOR (15 downto 0);
    do  : out STD_LOGIC_VECTOR (15 downto 0);
    en  : out STD_LOGIC;
    we  : out STD_LOGIC_VECTOR (0 downto 0);
    bramclk : out STD_LOGIC
  );
end pwm_wrapper;




architecture Behavioral of pwm_wrapper is
  signal addr : std_logic_vector (3 downto 0) := "0000";
  signal pwm_load : std_logic := '0';
  constant unused_a : std_logic_vector (4 downto 0) := (others => '0');
  
  signal idle_cnt : integer range 0 to 15 := 0;
  
  type state_t is (IDLE, PRELOAD, LOAD);
  signal state : state_t := IDLE;
begin

  bramclk <= clk;
  we <= "0";
  en <= '1';
  do <= (others => '0');
  a <= unused_a & addr;

  pwm : entity work.pwm_gen
    generic map (
      CLKIN_FREQ => CLKIN_FREQ
    )
    port map (
      clk => clk,
      rst => '0',
      PWM_EN_IN => pwm_load,
      PWM_OUT(15 downto 6) => open,
      PWM_OUT(5 downto 0) => leds,
      PWM_DATA_IN => di
    );

  process(clk) begin
    if rising_edge(clk) then
      case state is
      
      when IDLE =>
        pwm_load <= '0';
        idle_cnt <= idle_cnt - 1;
        if (idle_cnt = 0) then
          idle_cnt <= 15;
          state <= PRELOAD;
        end if;
      
      when PRELOAD =>
        state <= LOAD;
        addr <= addr + 1;
      
      when LOAD =>
        pwm_load <= '1';
        addr <= addr + 1;
        if (addr = x"F") then
          state <= IDLE;
        end if;

      end case;
    end if;
  end process;

end Behavioral;

