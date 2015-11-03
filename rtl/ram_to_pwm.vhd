
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ram_to_pwm is

  generic (
    PWM_CHANNELS      : integer := 16;
    PWM_SEND_INTERVAL : integer := 1024  -- cycles at 80 MHz
    );

  port (
    clk_gtp : in std_logic;             -- gtp parallel clock
    rst     : in std_logic;             -- active high

    BRAM_CLK : out std_logic;                       -- memory clock
    BRAM_A   : out std_logic_vector (8 downto 0);   -- memory address
    BRAM_DI  : out std_logic_vector (15 downto 0);  -- memory data in
    BRAM_DO  : in  std_logic_vector (15 downto 0);  -- memory data out
    BRAM_EN  : out std_logic;                       -- memory enable
    BRAM_WE  : out std_logic;                       -- memory write enable

    PWM_DATA_IN  : in  std_logic_vector (15 downto 0);
    PWM_EN_IN    : in  std_logic;
    PWM_DATA_OUT : out std_logic_vector (15 downto 0);
    PWM_EN_OUT   : out std_logic);

end entity ram_to_pwm;

architecture rtl of ram_to_pwm is

  signal bram_a_i : std_logic_vector (8 downto 0);

  -- PWM interface
  type t_pwm_send_state is (idle, read_ram, send);
  signal pwm_send_state : t_pwm_send_state;
  signal pwm_send_cnt   : integer range 0 to PWM_SEND_INTERVAL-1;  -- pwm send counter
  signal pwm_rcv_addr   : integer range 0 to PWM_CHANNELS-1;  -- pwm receive address

begin

  BRAM_CLK <= clk_gtp;
  BRAM_A   <= bram_a_i;
  BRAM_EN  <= '1';
  BRAM_DI  <= PWM_DATA_IN;

  -- 0-15 read, 16-31 write (16 PWMs)
  -- pwm data send and receive
  process (clk_gtp) is
  begin
    if rising_edge(clk_gtp) then
      -- default
      PWM_DATA_OUT <= (others => '0');
      PWM_EN_OUT   <= '0';
      -- send (read bram)
      case pwm_send_state is
        when idle =>
          if pwm_send_cnt = PWM_SEND_INTERVAL-1 then
            pwm_send_state <= read_ram;
            bram_a_i       <= '0' & X"00";
            pwm_send_cnt   <= 0;
          else
            pwm_send_state <= idle;
            pwm_send_cnt   <= pwm_send_cnt + 1;
          end if;
        when read_ram =>
          pwm_send_state <= send;
          PWM_DATA_OUT   <= BRAM_DO;
          PWM_EN_OUT     <= '1';
        when send =>
          if pwm_send_cnt /= PWM_CHANNELS-1 then
            pwm_send_state <= read_ram;
            bram_a_i       <= bram_a_i + 1;
            pwm_send_cnt   <= pwm_send_cnt + 1;
          else
            pwm_send_state <= idle;
          end if;
        when others => null;
      end case;
      -- receive (write to bram)
      if PWM_EN_IN = '1' then
        BRAM_WE  <= '1';
        bram_a_i <= std_logic_vector(to_unsigned(pwm_rcv_addr+16, 9));
        if pwm_rcv_addr = PWM_CHANNELS-1 then
          pwm_rcv_addr <= 0;
        else
          pwm_rcv_addr <= pwm_rcv_addr + 1;
        end if;
      else
        BRAM_WE <= '0';
      end if;
    end if;
  end process;

end architecture rtl;
