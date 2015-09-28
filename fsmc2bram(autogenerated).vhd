----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:43:03 07/21/2015 
-- Design Name: 
-- Module Name:    fsmc_glue - A_fsmc_glue 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsmc2bram is
  Generic (
    WA : positive := 16;
    WD : positive := 16
  );
	Port (
    clk : in std_logic;
    A : in STD_LOGIC_VECTOR (WA-1 downto 0);
    D : inout STD_LOGIC_VECTOR (WD-1 downto 0);
    NWE : in STD_LOGIC;
    NOE : in STD_LOGIC;
    NCE : in STD_LOGIC;
    NBL : in std_logic_vector (1 downto 0)
  );
end fsmc2bram;

-------------------------
architecture beh of fsmc2bram is

type state_t is (IDLE, ADDR, WRITE1, READ1);
signal state : state_t := IDLE;

signal fsmc_do : STD_LOGIC_VECTOR (WD-1 downto 0) := (others => '0');
signal address : natural range 0 to (2**WA)-1 := 0;

type ram_t is array (0 to (2**WA)-1) of std_logic_vector(WD-1 downto 0);
signal ram : ram_t := (others => (others => '0'));

begin

  D <= fsmc_do when (NCE = '0' and NOE = '0') else (others => 'Z');
  
  process(clk, NCE) begin
    if (NCE = '1') then
      state <= IDLE;
    elsif rising_edge(clk) then
      case state is
      when IDLE =>
        if (NCE = '0') then 
          address <= conv_integer(A);
          state <= ADDR;
        end if;

      when ADDR =>
        if (NWE = '0') then
          state <= WRITE1;
        else
          state <= READ1;
          address <= address + 1;
          fsmc_do <= ram(address); 
        end if;

      when WRITE1 =>
--        if (NBL = "00") then
--          ram(address) <= D;
--        elsif (NBL = "10") then
--          ram(address)(7 downto 0) <= D(7 downto 0);
--        elsif (NBL = "01") then
--          ram(address)(15 downto 8) <= D(15 downto 8);
--        end if;
        ram(address) <= D;
        address <= address + 1;

      when READ1 =>
        address <= address + 1;
        fsmc_do <= ram(address); 

      end case;
    end if;
  end process;
end beh;




