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

entity fsmc2bram is
    Port (
        hclk : in std_logic;
        A : in  STD_LOGIC_VECTOR (15 downto 0);
        D : inout  STD_LOGIC_VECTOR (15 downto 0);
        NWE : in  STD_LOGIC;
        NOE : in  STD_LOGIC;
        NCE : in  STD_LOGIC;
        NBL : in std_logic_vector (1 downto 0);
        
        bram_a : out STD_LOGIC_VECTOR (15 downto 0);
        bram_do : in STD_LOGIC_VECTOR (15 downto 0);
        bram_di : out STD_LOGIC_VECTOR (15 downto 0);
        bram_en : out STD_LOGIC := '0';
        bram_we : out std_logic_vector (1 downto 0)
     );
end fsmc2bram;

-------------------------
architecture beh of fsmc2bram is

type state_t is (IDLE, WRITE1, WRITE2, READ1, READ2);
signal state : state_t := IDLE;

--signal d_buf    : STD_LOGIC_VECTOR (15 downto 0) := (others => 'Z');
signal NWE_edge : STD_LOGIC_VECTOR (1 downto 0)  := (others => '0');
signal NOE_edge : STD_LOGIC_VECTOR (1 downto 0)  := (others => '0');

begin
  
  --D <= bram_do when ((state = READ1) or (state = READ2)) else (others => 'Z');
  --D <= (others => 'Z') when ((NWE = '0') or (state = WRITE1) or (state = WRITE2)) else bram_do;
  --D <= bram_do when (NOE = '0') else (others => 'Z');
  D <= bram_do when ((NOE = '0') and (NCE = '0')) else (others => 'Z');
  
  process(hclk) begin
		if falling_edge(hclk) then
      NWE_edge <= NWE_edge(0) & NWE;
      NOE_edge <= NOE_edge(0) & NOE;
    end if;
  end process;
  
  process(hclk) begin
    if falling_edge(hclk) then
      if (NCE = '1') then
        state <= IDLE;
        bram_we <= "00";
      else
        case state is
        when IDLE =>
          if (NOE_edge = "10") then -- NOE falling edge detected
            state <= READ1;
          -- возможно есть смысл перейти на "01", чтобы наверняка успевать
          -- тогда состояние WRITE2 становится нинужно
          elsif (NWE_edge = "10") then -- NWE falling edge detected
            state <= WRITE1;
          end if;
          
        when WRITE1 =>
          state <= WRITE2;
          bram_a <= A;
          bram_di <= D;
          bram_en <= '1';
          bram_we <= not NBL;
        when WRITE2 =>
          bram_en <= '0';
          bram_we <= "00";

        when READ1 =>
          state <= READ2;
          bram_a <= A;
          bram_en <= '1';
          bram_we <= "00";
        when READ2 =>
          bram_en <= '0';
          bram_we <= "00";
          
        end case;
      end if;
    end if;
  end process;

  
--	D <= mem_do when ((state = READ1) or (state = READ2)) else (others => 'Z');
--	mem_we <= not NBL when ((state = WRITE1) or (state = WRITE2)) else (others => '0');

--  bram_fsmc : entity work.bram_fsmc PORT MAP (
--    clka => hclk,
--    ena => EN_reg,
--    wea => WE_reg,
--    addra => A_reg,
--    dina => DI_reg,
--    douta => open,
--    
--    clkb => hclk,
--    enb => '0',
--    web => "11",
--    addrb => (others => '0'),
--    dinb => (others => '0'),
--    doutb => open
--  );

end beh;




