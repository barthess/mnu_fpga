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
	generic(
		datlat_N : positive := 2
	);

  Port (
    fsmc_clk : in std_logic;
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

type state_t is (IDLE, WRITE1, WRITE2, READ1);
signal state : state_t := IDLE;

signal a_buf : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal do_buf : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal di_buf : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

signal datlat : integer range 0 to datlat_N := 0;

begin
  
  --D <= bram_do when ((state = READ1) or (state = READ2)) else (others => 'Z');
  --D <= (others => 'Z') when ((NWE = '0') or (state = WRITE1) or (state = WRITE2)) else bram_do;
  --D <= bram_do when (NOE = '0') else (others => 'Z');
  D <= (others => 'Z') when ((NCE = '0') and (NWE = '0')) else do_buf;
  --bram_we <= not NBL when ((state = WRITE1) or (state = WRITE2) or (state = WRITE3) or (NWE = '0')) else "00";
  --bram_a <= A;

  
  process(fsmc_clk) begin
    if rising_edge(fsmc_clk) then
      case state is
      when IDLE =>
        datlat <= 0;
        bram_en <= '0';
        if (NCE = '0') then 
          a_buf <= A;
          if (NWE = '0') then
            state <= WRITE1;
          else
            state <= READ1;
          end if;
        end if;

      when WRITE1 =>
        datlat <= datlat + 1;
        if (datlat = datlat_N) then
          state <= WRITE2;
          bram_en <= '1';
          di_buf <= D;
          a_buf  <= a_buf + 1;
        end if;

      when WRITE2 =>
        di_buf <= D;
        a_buf  <= a_buf + 1;
        bram_di <= di_buf; 
        bram_a  <= a_buf; 
        if (NWE = '1' and NCE = '1') then
          state <= IDLE;
          bram_en <= '0';
        end if;

      when READ1 =>
        do_buf <= x"DEAD";
        state <= IDLE;

      end case;
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




