----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:12:13 09/18/2015 
-- Design Name: 
-- Module Name:    spi2bram - Behavioral 
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

entity spi2bram is
    Port ( hclk : in  STD_LOGIC;
           ssel_i : in  STD_LOGIC;
           mosi_i : in  STD_LOGIC;
           miso_o : out  STD_LOGIC;
           sck_i : in  STD_LOGIC);
end spi2bram;

architecture Behavioral of spi2bram is

begin


end Behavioral;

