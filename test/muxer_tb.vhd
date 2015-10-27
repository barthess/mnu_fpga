--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:07:05 10/27/2015
-- Design Name:   
-- Module Name:   /home/barthess/projects/xilinx/mnu/test/muxer_tb.vhd
-- Project Name:  mnu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: muxer
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
 
ENTITY muxer_tb IS
  generic (
    AW   : positive := 4; -- address width for multiplexers (select bits count)
    DW   : positive := 2; -- data bus width 
    cnt  : positive := 16  -- output ports count
  );
END muxer_tb;
 
ARCHITECTURE behavior OF muxer_tb IS 

   --Inputs
   signal A : std_logic_vector(AW-1 downto 0)     := (others => '0');
   signal i : std_logic_vector(DW*cnt-1 downto 0) := (others => '0');

 	--Outputs
   signal o : std_logic_vector(DW-1 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.muxer 
   generic map (
      AW => AW,
      DW => DW,
      cnt => cnt
   )
   PORT MAP (
          A => A,
          i => i,
          o => o
        );

   -- Stimulus process
   stim_proc: process
   begin		

      i <= (2 downto 0 => '1', others => '0');
      wait for 10 ns;
      
      A <= "0001";
      wait for 10 ns;
      
      i <= (others => '1');
      wait for 10 ns;
      
      A <= "1111";
      wait for 10 ns;
      
      i <= (1 downto 0 => '0', others => '1');
      wait for 10 ns;
      
      wait;
   end process;

END;
