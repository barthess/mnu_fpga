
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
    clk_smp : in std_logic;             -- sampling clock
    clk_gtp : in std_logic;             -- gtp parallel clock
    rst     : in std_logic;             -- active high

    CLK_FSMC : in  std_logic;                       -- memory clock
    A_IN     : in  std_logic_vector (8 downto 0);   -- memory address
    D_IN     : in  std_logic_vector (15 downto 0);  -- memory data in
    D_OUT    : out std_logic_vector (15 downto 0);  -- memory data out
    EN_IN    : in  std_logic;                       -- memory enable
    WE_IN    : in  std_logic;                       -- memory write enable

    PWM_DATA_IN  : in  std_logic_vector (15 downto 0);
    PWM_EN_IN    : in  std_logic;
    PWM_DATA_OUT : out std_logic_vector (15 downto 0);
    PWM_EN_OUT   : out std_logic);

end entity ram_to_pwm;

architecture rtl of ram_to_pwm is

  -- Memory space
  type t_pwm_ram is array (0 to PWM_CHANNELS-1) of std_logic_vector (15 downto 0);
  signal pwm_from_mcu : t_pwm_ram;
  signal pwm_to_mcu   : t_pwm_ram;

  signal clk_fsmc_i   : std_logic;
  signal clk_fsmc_d_i : std_logic;      -- previous value
  signal a_i          : std_logic_vector (8 downto 0);
  signal d_i          : std_logic_vector (15 downto 0);
  signal en_i         : std_logic;
  signal we_i         : std_logic;

  signal pwm_num_i : integer;           -- 0-15 read, 16-31 write (16 PWMs)

  signal fsmc_wr : std_logic;
  signal fsmc_rd : std_logic;

  -- PWM interface
  type t_pwm_send_state is (idle, send, pause);
  signal pwm_send_state : t_pwm_send_state;
  signal pwm_send_cnt   : integer range 0 to PWM_SEND_INTERVAL-1;  -- pwm send counter
  signal pwm_rcv_addr   : integer range 0 to PWM_CHANNELS-1;  -- pwm receive address

begin

  -- input sampling
  process (clk_smp) is
  begin
    if rising_edge(clk_smp) then
      clk_fsmc_i   <= CLK_FSMC;
      clk_fsmc_d_i <= clk_fsmc_i;
      a_i          <= A_IN;
      d_i          <= D_IN;
      en_i         <= EN_IN;
      we_i         <= WE_IN;
    end if;
  end process;

  pwm_num_i <= to_integer(unsigned(a_i(4 downto 0)));

  fsmc_rd <= '1' when clk_fsmc_d_i = '0' and clk_fsmc_i = '1' and en_i = '1' and we_i = '0'
             else '0';
  fsmc_wr <= '1' when clk_fsmc_d_i = '0' and clk_fsmc_i = '1' and en_i = '1' and we_i = '1'
             else '0';

  -- pwm memory (mcu interface)
  process (clk_smp) is
  begin
    if rising_edge(clk_smp) then
      D_OUT <= (others => '0');
      case pwm_num_i is
        when 0 to PWM_CHANNELS-1 =>               -- 0-15 read
          if fsmc_rd = '1' then
            D_OUT <= pwm_to_mcu (pwm_num_i);
          end if;
        when PWM_CHANNELS to PWM_CHANNELS*2-1 =>  -- 16-31 write
          if fsmc_wr = '1' then
            pwm_from_mcu (pwm_num_i-PWM_CHANNELS) <= d_i;
          end if;
        when others => null;
      end case;
    end if;
  end process;

  -- pwm data send (pre_tx interface)
  process (clk_gtp) is
  begin
    if rising_edge(clk_gtp) then
      -- default
      PWM_DATA_OUT <= (others => '0');
      PWM_EN_OUT   <= '0';
      case pwm_send_state is
        when idle =>
          if pwm_send_cnt = PWM_SEND_INTERVAL-1 then
            pwm_send_state <= send;
            pwm_send_cnt   <= 0;
            PWM_EN_OUT     <= '1';
            PWM_DATA_OUT   <= pwm_from_mcu (0);
          else
            pwm_send_state <= idle;
            pwm_send_cnt   <= pwm_send_cnt + 1;
          end if;
        when send =>
          pwm_send_state <= pause;
        when pause =>
          if pwm_send_cnt = PWM_CHANNELS-1 then
            pwm_send_state <= idle;
            pwm_send_cnt   <= 0;
          else
            pwm_send_state <= send;
            pwm_send_cnt   <= pwm_send_cnt + 1;
            PWM_EN_OUT     <= '1';
            PWM_DATA_OUT   <= pwm_from_mcu (pwm_send_cnt + 1);
          end if;
        when others => null;
      end case;
    end if;
  end process;

  -- pwm data receive (post_rx interface)
  process (clk_gtp, rst) is
  begin
    if rst = '1' then
      pwm_rcv_addr <= 0;
    elsif rising_edge(clk_gtp) then
      if PWM_EN_IN = '1' then
        pwm_to_mcu (pwm_rcv_addr) <= PWM_DATA_IN;
        if pwm_rcv_addr = PWM_CHANNELS-1 then
          pwm_rcv_addr <= 0;
        else
          pwm_rcv_addr <= pwm_rcv_addr + 1;
        end if;
      end if;
    end if;
  end process;

end architecture rtl;
