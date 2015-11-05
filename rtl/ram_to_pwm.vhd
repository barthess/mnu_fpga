library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

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

architecture rtl of ram_to_pwm is
	signal bram_a_i : std_logic_vector(8 downto 0);

	type t_state is (idle, wr_ram, wr_pause, rd_ram, send_pwm);
	signal state   : t_state;
	signal pwm_cnt : integer range 0 to PWM_CHANNELS - 1; -- write/read counter

begin
	BRAM_CLK <= clk_gtp;
	BRAM_A   <= bram_a_i;

	pwm_trx : process(clk_gtp, rst) is
	begin
		if rst = '1' then
			PWM_DATA_OUT <= (others => '0');
			PWM_EN_OUT   <= '0';
			state        <= idle;
			BRAM_EN      <= '0';
			BRAM_WE      <= '0';
		elsif rising_edge(clk_gtp) then
			-- defaults
			PWM_DATA_OUT <= (others => '0');
			PWM_EN_OUT   <= '0';
			BRAM_EN      <= '0';
			BRAM_WE      <= '0';
			case state is
				when idle =>
					if PWM_EN_IN = '1' then
						state    <= wr_ram;
						pwm_cnt  <= 0;
						BRAM_WE  <= '1';
            BRAM_EN      <= '1';
						bram_a_i <= '1' & X"02"; -- 0x100 + 2, temporary
						BRAM_DI  <= PWM_DATA_IN;
					else
						state <= idle;
					end if;
				when wr_ram =>
					state <= wr_pause;
				when wr_pause =>
					if pwm_cnt /= PWM_CHANNELS - 1 then
						state    <= wr_ram;
						pwm_cnt  <= pwm_cnt + 1;
						BRAM_WE  <= '1';
            BRAM_EN      <= '1';
						bram_a_i <= bram_a_i + 1;
						BRAM_DI  <= PWM_DATA_IN;
					else
						state    <= rd_ram;
						pwm_cnt  <= 0;
            BRAM_EN      <= '1';
						bram_a_i <= '0' & X"02"; -- 0x0 + 2, temporary
					end if;
				when rd_ram =>
          state        <= send_pwm;
					PWM_EN_OUT   <= '1';
					PWM_DATA_OUT <= BRAM_DO;					
				when send_pwm =>
					if pwm_cnt /= PWM_CHANNELS - 1 then
						state    <= rd_ram;
            BRAM_EN      <= '1';
						pwm_cnt  <= pwm_cnt + 1;
						bram_a_i <= bram_a_i + 1;
					else
						state <= idle;
					end if;
			end case;
		end if;
	end process pwm_trx;

end architecture rtl;
