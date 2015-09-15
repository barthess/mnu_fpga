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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsmc is
    Port (
        hclk : in std_logic;
        
        A : in  STD_LOGIC_VECTOR (15 downto 0);
        D : inout  STD_LOGIC_VECTOR (15 downto 0);
        NWE : in  STD_LOGIC;
        NOE : in  STD_LOGIC;
        NCE : in  STD_LOGIC;
        NBL : in std_logic_vector (1 downto 0);
        
        mem_do : out std_logic_vector (15 downto 0);
        mem_di : in std_logic_vector (15 downto 0);
        mem_a  : out std_logic_vector (15 downto 0);
        mem_we : out std_logic_vector (1 downto 0);
        mem_en : out std_logic
     );
end fsmc;

-------------------------
architecture a_fsmc of fsmc is

type state_t is (IDLE, WRITE1, WRITE2);
signal state : state_t := IDLE;

signal A_reg : STD_LOGIC_VECTOR (15 downto 0);
signal DO_reg : STD_LOGIC_VECTOR (15 downto 0);
signal NWE_edge : STD_LOGIC_VECTOR (1 downto 0) := (others => '0');

begin

  mem_a <= A_reg;
  mem_do <= DO_reg;
  
	process(hclk) begin
		if rising_edge(hclk) then
      NWE_edge <= NWE_edge(0) & NWE;
    end if;
  end process;

  process(hclk) begin
    if rising_edge(hclk) then
      if (NCE = '1') then
        state <= IDLE;
      else
        case state is
        when IDLE =>
          if (NWE_edge = "10") then
            state <= WRITE1;
            A_reg <= A;
            DO_reg <= D;
            mem_en <= '1';
            mem_we <= (not NBL);
          end if;
        when WRITE1 =>
          state <= WRITE2;
        when WRITE2 =>
          -- empty
        end case;
      end if;
    end if;
  end process;
    
--	D <= mem_do when ((state = READ1) or (state = READ2)) else (others => 'Z');
--	mem_we <= not NBL when ((state = WRITE1) or (state = WRITE2)) else (others => '0');

end a_fsmc;




