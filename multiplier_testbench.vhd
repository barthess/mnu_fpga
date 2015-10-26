--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:01:45 10/26/2015
-- Design Name:   
-- Module Name:   /home/barthess/projects/xilinx/mnu/multiplier_testbench.vhd
-- Project Name:  mnu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: multiplier
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY multiplier_testbench IS
END multiplier_testbench;
 
ARCHITECTURE behavior OF multiplier_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT multiplier
    Generic (
      AW : positive
    );
    PORT(
         clk : IN  std_logic;
         ce : IN  std_logic;
         rdy : OUT  std_logic;
         row : IN  std_logic_vector(4 downto 0);
         col : IN  std_logic_vector(4 downto 0);
         op0_di : IN  std_logic_vector(63 downto 0);
         op1_di : IN  std_logic_vector(63 downto 0);
         res_do : OUT  std_logic_vector(63 downto 0);
         op0_a : OUT  std_logic_vector(AW-1 downto 0);
         op1_a : OUT  std_logic_vector(AW-1 downto 0);
         res_a : OUT  std_logic_vector(AW-1 downto 0);
         we : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal ce : std_logic := '0';
   signal row : std_logic_vector(4 downto 0) := (others => '0');
   signal col : std_logic_vector(4 downto 0) := (others => '0');
   signal op0_di : std_logic_vector(63 downto 0) := (others => '0');
   signal op1_di : std_logic_vector(63 downto 0) := (others => '0');

 	--Outputs
   signal rdy : std_logic;
   signal res_do : std_logic_vector(63 downto 0);
   signal op0_a : std_logic_vector(9 downto 0);
   signal op1_a : std_logic_vector(9 downto 0);
   signal res_a : std_logic_vector(9 downto 0);
   signal we : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: multiplier 
   generic map (
      AW => 10
   )
   PORT MAP (
          clk => clk,
          ce => ce,
          rdy => rdy,
          row => row,
          col => col,
          op0_di => op0_di,
          op1_di => op1_di,
          res_do => res_do,
          op0_a => op0_a,
          op1_a => op1_a,
          res_a => res_a,
          we => we
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 1 ns;
      
      op0_di <= x"3ff4ccccc0000000";
      op1_di <= x"400dae1480000000";
      row <= "00010";
      col <= "00010";
      ce <= '1';
      
      wait for 200 ns;
      ce <= '0';

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;

