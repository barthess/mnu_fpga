
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity post_rx_mnu is
  port (
    clk               : in  std_logic;  -- RXUSRCLK8
    rst               : in  std_logic;
    GTP_RXDATA        : in  std_logic_vector (7 downto 0);
    GTP_CHARISK       : in  std_logic;
    GTP_BYTEISALIGNED : in  std_logic;
    USART1_RX         : out std_logic;  -- MCU UART
    USART1_CTS        : out std_logic
    );
end entity post_rx_mnu;

architecture gtp0 of post_rx_mnu is     -- MORS link

  type post_rx_state is (comma, payload);
  signal state           : post_rx_state;
  signal usart1_rx_prev  : std_logic := '1';
  signal usart1_cts_prev : std_logic := '1';

begin

  process (clk, rst) is
  begin
    if rst = '1' then
      USART1_RX  <= '1';
      USART1_CTS <= '1';
      state      <= comma;
    elsif rising_edge(clk) then
      case state is
        when comma =>
          if (GTP_BYTEISALIGNED = '0' or GTP_CHARISK = '1') then
            state      <= comma;
            USART1_RX  <= usart1_rx_prev;
            USART1_CTS <= usart1_cts_prev;
          elsif (GTP_BYTEISALIGNED = '1' and GTP_CHARISK = '0') then
            state           <= payload;
            USART1_RX       <= GTP_RXDATA(0);
            USART1_CTS      <= GTP_RXDATA(1);
            usart1_rx_prev  <= GTP_RXDATA(0);
            usart1_cts_prev <= GTP_RXDATA(1);
          end if;
        when payload =>
          if (GTP_BYTEISALIGNED = '0' or GTP_CHARISK = '1') then
            state      <= comma;
            USART1_RX  <= usart1_rx_prev;
            USART1_CTS <= usart1_cts_prev;
          elsif (GTP_BYTEISALIGNED = '1' and GTP_CHARISK = '0') then
            state           <= payload;
            USART1_RX       <= GTP_RXDATA(0);
            USART1_CTS      <= GTP_RXDATA(1);
            usart1_rx_prev  <= GTP_RXDATA(0);
            usart1_cts_prev <= GTP_RXDATA(1);
          end if;
            when others => null;
      end case;
    end if;
  end process;

end architecture gtp0;

