--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:00:08 10/29/2015
-- Design Name:   
-- Module Name:   /home/barthess/projects/xilinx/mnu/test/demuxer_tb.vhd
-- Project Name:  mnu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: demuxer
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
 
ENTITY demuxer_tb IS
generic (
  AW : positive := 3;  -- address width (select bits count)
  DW : positive := 2;  -- data width 
  cnt : positive := 8  -- actual outputs count
);
END demuxer_tb;
 
 
ARCHITECTURE behavior OF demuxer_tb IS 
    --Inputs
   signal A  : std_logic_vector(AW-1 downto 0) := (others => '0');
   signal di : std_logic_vector(DW-1 downto 0) := (others => '0');

 	--Outputs
   signal do : std_logic_vector(cnt*DW-1 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.demuxer 
   generic map (
      AW => AW,
      DW => DW,
      cnt => cnt
   )
   PORT MAP (
      A  => A,
      di => di,
      do => do
    );

   -- Stimulus process
  stim_proc: process
    variable from : integer;
    variable down : integer;
    variable ref : std_logic_vector(cnt*DW-1 downto 0);
  begin		
    for n in 0 to 2**AW-1 loop
      
      A <= std_logic_vector(to_unsigned(n, AW));
      
      if (n > cnt-1) then -- overflow test
        di <= (others => '1');
        wait for 10 ns;
        ref := (others => '0');
        assert do = ref
          report "overflow test failed"
          severity Failure;
      else
        from := DW*(n+1)-1;
        down := DW*n;

        di <= (others => '0');
        wait for 10 ns;
        ref := (others => '0');
        assert do = ref
          report "zero test failed"
          severity Failure;

        di <= (others => '1');
        wait for 10 ns;
        ref := (from downto down => '1', others => '0');
        assert do = ref
          report "ones test failed"
          severity Failure;
      end if;
    end loop;
    wait;
  end process;
END;
