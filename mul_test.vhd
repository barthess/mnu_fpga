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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

-- Non standard library from synopsis (for dev_null functions)
use ieee.std_logic_misc.all;

entity mul_test is
    Port (
        clk : in  STD_LOGIC;
        fake_out : out  std_logic
    );
end mul_test;

architecture Behavioral of mul_test is

signal m_a_proxy : std_logic_vector (63 downto 0);
signal m_b_proxy : std_logic_vector (63 downto 0);
signal m_result_proxy : std_logic_vector (63 downto 0);
signal m_fake_out : std_logic_vector (63 downto 0);

begin

	m_a : entity work.bram_mul port map (
		clka  => clk,
		wea   => (others => '0'),
		addra => (others => '0'),
		dina  => (others => '0'),
		douta => m_a_proxy
	);

	m_b : entity work.bram_mul port map (
		clka  => clk,
		wea   => (others => '0'),
		addra => (others => '0'),
		dina  => (others => '0'),
		douta => m_b_proxy
	);
    
    m_result : entity work.bram_mul port map (
		clka  => clk,
		wea   => (others => '1'),
		addra => (others => '0'),
		dina  => m_result_proxy,
		douta => m_fake_out
	);
    
    fake_out <= or_reduce(m_fake_out);
    
    mul : entity work.double_mul PORT MAP (
        a => m_a_proxy,
        b => m_b_proxy,
        clk => clk,
        ce => '1',
        result => m_result_proxy
    );
    
end Behavioral;

