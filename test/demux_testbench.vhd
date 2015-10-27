--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:55:49 10/21/2015
-- Design Name:   
-- Module Name:   /home/barthess/projects/xilinx/mnu/demux_testbench.vhd
-- Project Name:  mnu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: bus_matrix_helper
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
USE ieee.numeric_std.ALL;
 
ENTITY busmatrix_helper_tb IS
END busmatrix_helper_tb;
 
ARCHITECTURE behavior OF busmatrix_helper_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT busmatrix_helper
    generic (
      AW   : positive; -- address width for multiplexers (select bits count)
      icnt : positive; -- input ports count
      ocnt : positive  -- output ports count
    );
    PORT(
         i : IN  std_logic_vector(8 downto 0);
         o : OUT  std_logic_vector(20 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal i : std_logic_vector(8 downto 0) := (others => '0');

 	--Outputs
   signal o : std_logic_vector(20 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: busmatrix_helper 
   generic map (
    AW => 3,
    icnt => 3,
    ocnt => 7
   )
   PORT MAP (
      i => i,
      o => o
    );

   -- Stimulus process
   stim_proc: process
   begin		
      wait for 1 ns;	
      i <= "001010110";
      wait for 1 ns;
      i <= "110101010";
      wait;
   end process;

END;
