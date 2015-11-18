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
USE ieee.std_logic_unsigned.all;
entity ram_to_pwm_se is
 port(
      rst      : in  std_logic;
      clk_tx   : in  std_logic;
      clk_rx   : in  std_logic;

      BRAM_TX_CLK : out std_logic;
      BRAM_TX_A   : out std_logic_vector(8 downto 0);
      BRAM_TX_DI  : in std_logic_vector(15 downto 0);
      BRAM_TX_DO  : out std_logic_vector(15 downto 0);
      BRAM_TX_EN  : out std_logic;
      BRAM_TX_WE  : out std_logic;

      BRAM_RX_CLK : out std_logic;
      BRAM_RX_A   : out std_logic_vector(8 downto 0);
      BRAM_RX_DI  : in std_logic_vector(15 downto 0);
      BRAM_RX_DO  : out std_logic_vector(15 downto 0);
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
  type state_t is (reset, idle, busy);
    
  signal state_rx  : state_t;
  signal state_tx  : state_t;
  
  signal cnt_rx : std_logic_vector(5 downto 0);
  signal cnt_tx : std_logic_vector(7 downto 0) := (others =>'0');
  signal cnt_lim_tx : std_logic_vector(7 downto 0) := (others =>'0');
  constant cnt_lim_rx : std_logic_vector(5 downto 0) := "100101";

BEGIN
 
  BRAM_RX_A <= "00000"&cnt_rx(4 downto 1) when cnt_rx <= std_logic_vector(to_unsigned(31,6)) else
               "100000000" when cnt_rx >= std_logic_vector(to_unsigned(32,6)) and cnt_rx <= std_logic_vector(to_unsigned(33,6)) else
               "100000010" when cnt_rx >= std_logic_vector(to_unsigned(34,6)) and cnt_rx <= std_logic_vector(to_unsigned(35,6)) else
               "100000011" when cnt_rx >= std_logic_vector(to_unsigned(36,6)) and cnt_rx <= std_logic_vector(to_unsigned(37,6)) else
               "000000000";
               
  BRAM_TX_A <= "00"&cnt_tx(7 downto 1);
   
  BRAM_TX_CLK  <= clk_tx;
  BRAM_RX_CLK  <= clk_rx;
  
  -- control    
    
  BRAM_TX_EN   <= '1';
  BRAM_RX_EN   <= '1';
  
  BRAM_RX_DO   <= PWM_DATA_IN;
  PWM_DATA_OUT <= BRAM_TX_DI;
  BRAM_TX_DO <= (others => '0');
  BRAM_TX_WE   <= '0';
  BRAM_RX_WE   <= PWM_EN_IN;

-- control  
  PWM_EN_OUT <= cnt_tx(0) when state_tx = busy else
                '0';
    
  state_rx_proc : process(rst, clk_rx) is
  begin
    if rst = '1' then
      state_rx <= reset;
    elsif falling_edge(clk_rx) then
      case state_rx is
		    when reset =>
		      state_rx <= idle;
        when idle =>
          if PWM_EN_IN = '1' then
            state_rx <= busy; 
          end if;  
        when busy => 
          if (cnt_rx = "000000") then
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
      state_tx <= reset; 
      cnt_lim_tx <= (others=>'0');
    elsif rising_edge(clk_tx) then
      if (cnt_tx = cnt_lim_tx) then
        case state_tx is
          when reset =>
            state_tx <= idle;
            cnt_lim_tx <= std_logic_vector(to_unsigned(10,8)); 
          when idle =>
            state_tx <= busy;
            cnt_lim_tx <= std_logic_vector(to_unsigned(31,8));
          when busy => 
            state_tx <= idle;
            cnt_lim_tx <= std_logic_vector(to_unsigned(255,8));
          when others =>
            state_tx <= idle;
            cnt_lim_tx <= std_logic_vector(to_unsigned(255,8));
        end case;
      end if;
    end if;
  end process state_tx_proc;

--state counters 
  cnt_rx_proc : process(rst, clk_rx) is
  begin
    if rst = '1' then
      cnt_rx <= (others => '0');
    elsif rising_edge(clk_rx) then
      if state_rx = idle or cnt_rx = cnt_lim_rx then
        cnt_rx <= (others => '0');
      else
        cnt_rx <= cnt_rx + "1";
      end if;
    end if;  
  end process cnt_rx_proc;

  cnt_tx_proc : process(rst, clk_tx) is
  begin
    if rst = '1' then
      cnt_tx <= (others => '0');
    elsif rising_edge(clk_tx) then
      if cnt_tx = cnt_lim_tx then
        cnt_tx <= (others => '0');
      else
        cnt_tx <= cnt_tx + "1";
      end if;
    end if;  
  end process cnt_tx_proc;  
 
END ARCHITECTURE behav;

