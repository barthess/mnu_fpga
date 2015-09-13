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

entity fsmc_bridge is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           D : inout  STD_LOGIC_VECTOR (15 downto 0);
           NWE : in  STD_LOGIC;
           NOE : in  STD_LOGIC;
           NCE : in  STD_LOGIC;
			  NBL : in std_logic_vector (1 downto 0);
			  hclk : in std_logic;
			  dbg : out std_logic_vector (5 downto 0)
			 );
end fsmc_bridge;

-------------------------
architecture A_fsmc_bridge of fsmc_bridge is

type state_t is (IDLE, WRITE1, WRITE2, WRITE3, READ1, READ2);
signal state : state_t := IDLE;

signal mem_do : std_logic_vector (15 downto 0);
signal mem_we : std_logic_vector (1 downto 0);
signal mem_clk : std_logic := '0';

begin
	dbg(0) <= NCE;
	dbg(1) <= NOE;
	dbg(2) <= NWE;
	dbg(3) <= A(0);
	dbg(4) <= mem_do(0);
	dbg(5) <= mem_clk;
	
	bram : entity work.blk_mem_fsmc port map (
		clka  => mem_clk,
		wea   => mem_we,
		addra => A,
		dina  => D,
		douta => mem_do
	);
	
	-- Как работает FSMC шина в режимах R/W при настройке на максимальную скорость
	-- R
	-- 1) адрес выставляется за 1 тик до NCE.
	-- 2) фронты и срезы NOE и NCE синхронны
	-- 3) пересылка данных с шины D в память проца (предположительно) по фронту NOE
	-- W
	-- 1) адрес и данные выставляются по срезу NCE
	-- 2) срезы NWE и NCE синхронны
	-- 3) фронт NWE приходит на 1 тик раньше фронта NCE
	D <= mem_do when ((state = READ1) or (state = READ2)) else (others => 'Z');
	mem_we <= not NBL when ((state = WRITE1) or (state = WRITE2)) else (others => '0');
	
	process(hclk)begin
		if rising_edge(hclk) then
			if (NCE = '1') then
				state <= IDLE;
				mem_clk <= '0';
			else
				if (NOE = '0') then
					state <= READ1;
					mem_clk <= '1';
				elsif (state = READ1) then
					state <= READ2;
					
				elsif ((state = IDLE) and (NWE = '0')) then
					state <= WRITE1;
				elsif (state = WRITE1) then
					state <= WRITE2;
				elsif (state = WRITE2) then
					state <= WRITE2;
					mem_clk <= '1';
				elsif ((state = WRITE3) and (NWE = '1')) then
					state <= IDLE;
				end if;
			end if;
		end if;
	end process;
end A_fsmc_bridge;




