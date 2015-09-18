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
           sck_i : in  STD_LOGIC
           
           bram_a  : out STD_LOGIC_VECTOR (15 downto 0);
           bram_do : in STD_LOGIC_VECTOR (15 downto 0);
           bram_di : out STD_LOGIC_VECTOR (15 downto 0);
           bram_en : out STD_LOGIC := '0';
           bram_we : out std_logic_vector (1 downto 0)
         );
end spi2bram;

architecture Behavioral of spi2bram is

type state_t is (IDLE, WRITE1, READ1);
signal state : state_t := IDLE;
signal A : STD_LOGIC_VECTOR (15 downto 0) := x"0000";

begin


  spi_slave : entity work.spi_slave port map (
    
  );






  process(hclk) begin
    if rising_edge(hclk) then
      case state is
      when IDLE =>
        if (NOE = '0') then -- NOE falling edge detected
          state <= READ1;
        elsif (NWE = '0') then -- NWE falling edge detected
          state <= WRITE1;
        end if;

      when WRITE1 =>
        state <= WRITE2;
        bram_di <= D;
      when WRITE2 =>
        state <= WRITE3;
        bram_en <= '1';
      when WRITE3 =>
        bram_en <= '0';
        if (NCE = '1' and NWE = '1') then
          state <= IDLE;
        end if;

      when READ1 =>
        state <= READ2;
        bram_en <= '1';
      when READ2 =>
        bram_en <= '0';
        if (NCE = '1' and NOE = '1') then
          state <= IDLE;
        end if;
        
      end case;
    end if;
  end process;



end Behavioral;






