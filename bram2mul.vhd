----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:26:35 09/24/2015 
-- Design Name: 
-- Module Name:    bram2mul - Behavioral 
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

entity bram2mul is
  Port ( 
    clk : in  STD_LOGIC;
    
    bram_di  : in  STD_LOGIC_VECTOR (63 downto 0);
    bram_do  : out  STD_LOGIC_VECTOR (63 downto 0);
    bram_a   : out  STD_LOGIC_VECTOR (11 downto 0);
    bram_we  : out  STD_LOGIC_VECTOR (7 downto 0);

    mul_en   : out  STD_LOGIC;
    mul_in1  : in  STD_LOGIC_VECTOR (63 downto 0);
    mul_in2  : in  STD_LOGIC_VECTOR (63 downto 0);
    mul_result : out  STD_LOGIC_VECTOR (63 downto 0)
  );
end bram2mul;


architecture Behavioral of bram2mul is

signal cycle    : std_logic_vector (7 downto 0)  := (others => 'U');      -- multiply cycle counter
signal op_a_buf : std_logic_vector (63 downto 0) := (others => 'U');
signal op_b_buf : std_logic_vector (63 downto 0) := (others => 'U');
signal ctrl_buf : std_logic_vector (63 downto 0) := (others => 'U');

begin


end Behavioral;





