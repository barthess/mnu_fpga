----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:10:38 07/17/2015 
-- Design Name: 
-- Module Name:    mux - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_mux is
    Port (
        i : in  STD_LOGIC_VECTOR (3 downto 0);
		o : out STD_LOGIC;
        sel : in  STD_LOGIC_VECTOR (1 downto 0)
    );
end uart_mux;

architecture rtl of uart_mux is
begin
	process(sel, i)
	begin
		case sel is
			when "00"	=> o <= i(0);
			when "01"	=> o <= i(1);
			when "10"	=> o <= i(2);
			when "11"	=> o <= i(3);
			when others => report "unreachable" severity failure;
		end case;
	end process;
end rtl;

