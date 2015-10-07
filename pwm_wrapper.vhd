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
  port (
    clk  : in  std_logic;
    leds : out STD_LOGIC_VECTOR (5 downto 0);
    
    a   : out STD_LOGIC_VECTOR (8 downto 0);
    di  : in  STD_LOGIC_VECTOR (15 downto 0)
  );
end pwm_wrapper;




architecture Behavioral of pwm_wrapper is
  signal addr : std_logic_vector (3 downto 0) := "0000";
begin

  pwm : entity work.pwm_gen
    generic map (
      CLKIN_FREQ => 90,
      PWM_PERIOD => X"4E20" 
    )
    port map (
      clk => clk,
      rst => '0',
      PWM_EN_IN => '1',
      PWM_OUT(5 downto 0) => leds,
      PWM_OUT(15 downto 6) => open,
      PWM_DATA_IN => di
    );

  process(clk) begin
    if rising_edge(clk) then
      a <= (others => '0');
      a(3 downto 0) <= addr;
      addr <= addr + 1;
    end if;
  end process;

end Behavioral;

