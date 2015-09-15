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
        NBL : in std_logic_vector (1 downto 0)
     );
end fsmc;

-------------------------
architecture a_fsmc of fsmc is

type state_t is (IDLE, WRITE1, WRITE2);
signal state : state_t := IDLE;

signal A_reg : STD_LOGIC_VECTOR (15 downto 0);
--signal DO_reg : STD_LOGIC_VECTOR (15 downto 0);
signal DI_reg : STD_LOGIC_VECTOR (15 downto 0);
signal NWE_edge : STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
signal EN_reg : STD_LOGIC := '0';
signal WE_reg : STD_LOGIC_VECTOR (1 downto 0) := "00";

begin

  bram : entity work.bram_fsmc PORT MAP (
    clka => hclk,
    ena => EN_reg,
    wea => WE_reg,
    addra => A_reg,
    dina => DI_reg,
    douta => open,
    
    clkb => hclk,
    enb => '0',
    web => "11",
    addrb => (others => '0'),
    dinb => (others => '0'),
    doutb => open
  );

  process(hclk) begin
		if falling_edge(hclk) then
      NWE_edge <= NWE_edge(0) & NWE;
    end if;
  end process;
  
  process(hclk) begin
    if falling_edge(hclk) then
      if (NCE = '1') then
        state <= IDLE;
      else
        case state is
        when IDLE =>
          if (NWE_edge = "10") then -- NWE falling edge detected
            state <= WRITE1;
          end if;
        when WRITE1 =>
          state <= WRITE2;
          A_reg <= A;
          DI_reg <= D;
          EN_reg <= '1';
          WE_reg <= "11";
        when WRITE2 =>
          EN_reg <= '0';
          WE_reg <= "00";
        end case;
      end if;
    end if;
  end process;

  D <= (others => 'Z');
--	D <= mem_do when ((state = READ1) or (state = READ2)) else (others => 'Z');
--	mem_we <= not NBL when ((state = WRITE1) or (state = WRITE2)) else (others => '0');

end a_fsmc;




