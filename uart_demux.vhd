----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:18:38 07/17/2015 
-- Design Name: 
-- Module Name:    demux - Behavioral 
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

entity uart_demux is
    Port (
        i : in  STD_LOGIC;
        o : out  STD_LOGIC_VECTOR (3 downto 0);
        sel : in  STD_LOGIC_VECTOR (1 downto 0)
    );
end demux;

architecture rtl of uart_demux is
begin
	process(sel, i)
	begin
		o <= "1111";
		case sel is
			when "00"	=> o(0) <= i;
			when "01"	=> o(1) <= i;
			when "10"	=> o(2) <= i;
			when "11"	=> o(3) <= i;
			when others => report "unreachable" severity failure;
		end case;
	end process;
end rtl;

