--
-- VHDL Architecture monoblock.ram_to_pwm.behav
--
-- Created:
--          by - muaddib.UNKNOWN (AMSTERDAM)
--          at - 10:27:58 09.11.2015
--
-- using Mentor Graphics HDL Designer(TM) 2012.1 (Build 6)
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.numeric_std.all;
entity ram_to_pwm_se is
 port(
      rst      : in  std_logic;
      clk_tx   : in  std_logic;
      clk_rx   : in  std_logic;


      BRAM_TX_CLK : out std_logic;
      BRAM_TX_A   : out std_logic_vector(8 downto 0);
      BRAM_TX_DI  : in  std_logic_vector(15 downto 0);
      BRAM_TX_DO  : out std_logic_vector(15 downto 0);
      BRAM_TX_EN  : out std_logic;
      BRAM_TX_WE  : out std_logic;

      BRAM_RX_CLK : out std_logic;
      BRAM_RX_A   : out std_logic_vector(8 downto 0);
      BRAM_RX_DO  : out std_logic_vector(15 downto 0);
      BRAM_RX_DI  : in  std_logic_vector(15 downto 0);
      BRAM_RX_EN  : out std_logic;
      BRAM_RX_WE  : out std_logic;


      PWM_DATA_IN  : in  std_logic_vector(15 downto 0);
      PWM_EN_IN    : in  std_logic;
      PWM_DATA_OUT : out std_logic_vector(15 downto 0);
      PWM_EN_OUT   : out std_logic
     );
end entity ram_to_pwm_se;

--
ARCHITECTURE behav OF ram_to_pwm_se IS
  type state_t is (idle, busy);
    
  signal state_rx  : state_t;
  signal state_tx  : state_t;
  
  signal cnt_rx : integer range 0 to 511;
  signal cnt_tx : integer range 0 to 511;
  signal cnt_lim_tx : integer range 0 to 511;
  signal cnt_lim_rx : integer range 0 to 511;
  signal bram_a_tx_cnt : std_logic_vector(9 downto 0);
  signal bram_a_rx_cnt : std_logic_vector(9 downto 0);

BEGIN
  BRAM_TX_DO <= (others => '0');
  
-- output  
  BRAM_TX_A <= bram_a_tx_cnt(9 downto 1);
  BRAM_RX_A <= bram_a_rx_cnt(9 downto 1);
  
  BRAM_TX_CLK  <= clk_tx;
  BRAM_RX_CLK  <= clk_rx;
  
  BRAM_TX_EN   <= '1';
  BRAM_RX_EN   <= '1';
  
  BRAM_RX_DO   <= PWM_DATA_IN;
  PWM_DATA_OUT <= BRAM_TX_DI;
  BRAM_TX_WE   <= '0';
  BRAM_RX_WE   <= PWM_EN_IN;

-- control  
  pwm_en_tx_proc : process(rst, clk_tx) is
  variable cnt_std : std_logic_vector(9 downto 0);
  begin
    if rst = '1' then
      PWM_EN_OUT   <= '0';
    elsif rising_edge(clk_tx) then
      cnt_std := std_logic_vector(to_unsigned(cnt_tx,10));
      if cnt_std(0) = '1' and state_tx = busy then  
        PWM_EN_OUT <= '1';
      else 
        PWM_EN_OUT <= '0'; 
      end if;
    end if;  
  end process pwm_en_tx_proc;
    
  bram_a_tx_proc : process(rst, clk_tx) is
  begin
    if rst = '1' then
      bram_a_tx_cnt <= (others=>'0');
    elsif rising_edge(clk_tx) then
      bram_a_tx_cnt <= std_logic_vector(to_unsigned(cnt_tx,10));
    end if;  
  end process bram_a_tx_proc;
  
  bram_a_rx_proc : process(rst, clk_rx) is
  begin
    if rst = '1' then
      bram_a_rx_cnt <= (others=>'0');
    elsif rising_edge(clk_rx) then
      bram_a_rx_cnt <= std_logic_vector(to_unsigned(cnt_rx+1,10));
    end if;  
  end process bram_a_rx_proc;
    
  state_rx_proc : process(rst, clk_rx) is
  begin
    if rst = '1' then
      state_rx <= idle;
      cnt_lim_rx <= 0; 
    elsif falling_edge(clk_rx) then
      case state_rx is
        when idle =>
          if PWM_EN_IN = '1' then
            state_rx <= busy; 
            cnt_lim_rx <= 30; 
          end if;  
        when busy => 
          if (cnt_rx = 0) then
            state_rx <= idle;
          end if;
        when others =>
          state_rx <= idle;
      end case;
    end if;
  end process state_rx_proc;  

  state_tx_proc : process(rst, clk_tx) is
  begin
    if rst = '1' then
      state_tx <= idle; 
      cnt_lim_tx <= 200;
    elsif rising_edge(clk_tx) then
      if (cnt_tx = 0) then
        case state_tx is
          when idle =>
            state_tx <= busy;
            cnt_lim_tx <= 32; 
          when busy => 
            state_tx <= idle;
            cnt_lim_tx <= 200;
          when others =>
            state_tx <= idle;
            cnt_lim_tx <= 200;
        end case;
      end if;
    end if;
  end process state_tx_proc;
 
  cnt_rx_proc : process(rst, clk_rx) is
  begin
    if rst = '1' then
      cnt_rx <= 0;
    elsif rising_edge(clk_rx) then
      if state_rx = idle then
        cnt_rx <= 0;
      else
        if cnt_rx = cnt_lim_rx then
          cnt_rx <= 0;
        else
          cnt_rx <= cnt_rx + 1;
        end if;
      end if;
    end if;  
  end process cnt_rx_proc;

  cnt_tx_proc : process(rst, clk_tx) is
  begin
    if rst = '1' then
      cnt_tx <= 1;
    elsif rising_edge(clk_tx) then
      if cnt_tx = cnt_lim_tx then
        cnt_tx <= 0;
      else
        cnt_tx <= cnt_tx + 1;
      end if;
    end if;  
  end process cnt_tx_proc;  
 
END ARCHITECTURE behav;

