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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY busmatrix_testbench IS
  generic (
    AW   : positive := 3; -- address width for multiplexers (select bits count)
    DW   : positive := 2; -- data bus width 
    icnt : positive := 3; -- input ports count
    ocnt : positive := 7  -- output ports count
  );
END busmatrix_testbench;
 
ARCHITECTURE behavior OF busmatrix_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT bus_matrix
    generic (
      AW   : positive; -- address width for multiplexers (select bits count)
      DW   : positive; -- data bus width 
      icnt : positive; -- input ports count
      ocnt : positive  -- output ports count
    );
    PORT(
        A : in  STD_LOGIC_VECTOR(AW*ocnt-1 downto 0);
        i : in  STD_LOGIC_VECTOR(icnt*DW-1 downto 0);
        o : out STD_LOGIC_VECTOR(ocnt*DW-1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal  A : STD_LOGIC_VECTOR(AW*ocnt-1 downto 0);
   signal  i : STD_LOGIC_VECTOR(icnt*DW-1 downto 0);

 	--Outputs
   signal  o : STD_LOGIC_VECTOR(ocnt*DW-1 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: bus_matrix 
   generic map (
     AW   => AW,
     DW   => DW,
     icnt => icnt,
     ocnt => ocnt
   )
   PORT MAP (
      A => A,
      i => i,
      o => o
    );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      i <= (others => '1');
      A <= (others => '0');

      -- insert stimulus here 

      
      wait for 100 ns;	
      i <= (others => '0');
      A <= (others => '0');
      
      wait for 100 ns;
      wait;
   end process;

END;
