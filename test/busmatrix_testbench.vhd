--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:59:24 10/21/2015
-- Design Name:   
-- Module Name:   /home/barthess/projects/xilinx/mnu/busmatrix_testbench.vhd
-- Project Name:  mnu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: bus_matrix
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY busmatrix_tb IS
  generic (
    AW   : positive := 3; -- address width for multiplexers (select bits count)
    DW   : positive := 2; -- data bus width 
    icnt : positive := 3; -- input ports count
    ocnt : positive := 7  -- output ports count
  );
END busmatrix_tb;
 
ARCHITECTURE behavior OF busmatrix_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT busmatrix
    generic (
      AW   : positive; -- address width for multiplexers (select bits count)
      DW   : positive; -- data bus width 
      icnt : positive; -- input ports count
      ocnt : positive  -- output ports count
    );
    PORT(
        A  : in  STD_LOGIC_VECTOR(AW*ocnt-1 downto 0);
        di : in  STD_LOGIC_VECTOR(icnt*DW-1 downto 0);
        do : out STD_LOGIC_VECTOR(ocnt*DW-1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal  A  : STD_LOGIC_VECTOR(AW*ocnt-1 downto 0);
   signal  di : STD_LOGIC_VECTOR(icnt*DW-1 downto 0);

 	--Outputs
   signal  do : STD_LOGIC_VECTOR(ocnt*DW-1 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: busmatrix 
   generic map (
     AW   => AW,
     DW   => DW,
     icnt => icnt,
     ocnt => ocnt
   )
   PORT MAP (
      A  => A,
      di => di,
      do => do
    );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 10 ns;	
      di <= (others => '1');
      A <= (others => '0');
      wait for 10 ns;	
      
      -- insert stimulus here 
--      A <= (others => '1');
--      wait for 10 ns;
      
--      A <= (3 => '0', others => '1');
--      wait for 10 ns;
      
      
      wait;
   end process;

END;
