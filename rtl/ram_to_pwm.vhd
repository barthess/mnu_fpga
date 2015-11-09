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
entity ram_to_pwm is
 generic(
  PWM_CHANNELS : integer := 16
 );

 port(
  clk_gtp      : in  std_logic;   -- gtp parallel clock
  rst          : in  std_logic;   -- active high

  BRAM_CLK     : out std_logic;   -- memory clock
  BRAM_A       : out std_logic_vector(8 downto 0); -- memory address
  BRAM_DI      : out std_logic_vector(15 downto 0); -- memory data in
  BRAM_DO      : in  std_logic_vector(15 downto 0); -- memory data out
  BRAM_EN      : out std_logic;   -- memory enable
  BRAM_WE      : out std_logic;   -- memory write enable

  PWM_DATA_IN  : in  std_logic_vector(15 downto 0);
  PWM_EN_IN    : in  std_logic;
  PWM_DATA_OUT : out std_logic_vector(15 downto 0);
  PWM_EN_OUT   : out std_logic);

end entity ram_to_pwm;

--
ARCHITECTURE behav OF ram_to_pwm IS
  
  type state_t is (wr_ram, rd_ram);
  signal state   : state_t;
  signal pwm_cnt : integer range 0 to PWM_CHANNELS - 1; -- write/read counter
  signal cnt : std_logic;
  signal bram_a_i : std_logic_vector(8 downto 0);
  
BEGIN
  BRAM_CLK <= clk_gtp;
  BRAM_A   <= bram_a_i;
  BRAM_EN <= '1';
  BRAM_DI <= PWM_DATA_IN;
  PWM_DATA_OUT <= BRAM_DO;
  
  cnt_proc : process(rst, clk_gtp) is
  begin
    if rst = '1' then
      cnt <= '0';
    elsif rising_edge(clk_gtp) then
      cnt <= not cnt;
    end if;  
  end process cnt_proc;
  
  bram_a_proc : process(rst, clk_gtp) is
  begin
    if rst = '1' then
      bram_a_i <= (others => '0');
    elsif rising_edge(clk_gtp) then
      if (state = rd_ram) then
        bram_a_i <= std_logic_vector(to_unsigned(pwm_cnt,9));
      elsif (state = wr_ram) then
        bram_a_i <= std_logic_vector(to_unsigned(pwm_cnt+255,9));
      else
        bram_a_i <= (others => '0');
      end if;
    end if;  
  end process bram_a_proc;
  
  pwm_trx : process(rst, clk_gtp) is
  begin
    if rst = '1' then
      PWM_EN_OUT   <= '0';
      BRAM_WE      <= '0';
    elsif rising_edge(clk_gtp) then
      if cnt = '1' then
        if state = wr_ram then   
          PWM_EN_OUT <= '0';
          BRAM_WE    <= '1';
        elsif state = rd_ram then
          PWM_EN_OUT <= '1';
          BRAM_WE    <= '0';
        else
          PWM_EN_OUT   <= '0'; 
        end if;
      else
        PWM_EN_OUT <= '0';
        BRAM_WE    <= '0';  
      end if;
    end if;  
  end process pwm_trx;
  
  state_proc : process(rst, clk_gtp) is
  begin
    if rst = '1' then
      state <= rd_ram;
    elsif rising_edge(clk_gtp) then
      case state is
      when rd_ram => 
        if ((pwm_cnt = PWM_CHANNELS - 1) and (cnt = '1')) then
          state <= wr_ram;
        end if;
      when wr_ram => 
        if ((pwm_cnt = PWM_CHANNELS - 1) and (cnt = '1')) then
          state <= rd_ram;
        end if;
      when others =>
      end case;
    end if;  
  end process state_proc;
  
  pwm_cnt_proc : process(rst, clk_gtp) is
  begin
    if rst = '1' then
      pwm_cnt <= 0;
    elsif rising_edge(clk_gtp) then
      if (((state = wr_ram) or (state = rd_ram)) and (cnt = '1')) then
        if pwm_cnt < PWM_CHANNELS - 1 then
          pwm_cnt  <= pwm_cnt + 1;
        else
          pwm_cnt <= 0;
        end if;
      end if;
    end if;  
  end process pwm_cnt_proc;
  
  
--  pwm_trx : process(clk_gtp, rst) is
--  begin
--    if rst = '1' then
--     PWM_DATA_OUT <= (others => '0');
--     PWM_EN_OUT   <= '0';
--     state        <= idle;
--     BRAM_EN      <= '0';
--     BRAM_WE      <= '0';
--  elsif rising_edge(clk_gtp) then
--   -- defaults
--   PWM_DATA_OUT <= (others => '0');
--   PWM_EN_OUT   <= '0';
--   BRAM_EN      <= '0';
--   BRAM_WE      <= '0';
--   case state is
--    when idle =>
--     if PWM_EN_IN = '1' then
--      state    <= wr_ram;
--      pwm_cnt  <= 0;
--      BRAM_WE  <= '1';
--            BRAM_EN      <= '1';
--      bram_a_i <= '1' & X"02"; -- 0x100 + 2, temporary
--      BRAM_DI  <= PWM_DATA_IN;
--     else
--      state <= idle;
--     end if;
--    when wr_ram =>
--     state <= wr_pause;
--    when wr_pause =>
--     if pwm_cnt /= PWM_CHANNELS - 1 then
--      state    <= wr_ram;
--      pwm_cnt  <= pwm_cnt + 1;
--      BRAM_WE  <= '1';
--            BRAM_EN      <= '1';
--      bram_a_i <= bram_a_i + 1;
--      BRAM_DI  <= PWM_DATA_IN;
--     else
--      state    <= rd_ram;
--      pwm_cnt  <= 0;
--            BRAM_EN      <= '1';
--      bram_a_i <= '0' & X"02"; -- 0x0 + 2, temporary
--     end if;
--    when rd_ram =>
--          state        <= send_pwm;
--     PWM_EN_OUT   <= '1';
--     PWM_DATA_OUT <= BRAM_DO;     
--    when send_pwm =>
--     if pwm_cnt /= PWM_CHANNELS - 1 then
--      state    <= rd_ram;
--            BRAM_EN      <= '1';
--      pwm_cnt  <= pwm_cnt + 1;
--      bram_a_i <= bram_a_i + 1;
--     else
--      state <= idle;
--     end if;
--   end case;
--  end if;
-- end process pwm_trx;
END ARCHITECTURE behav;

